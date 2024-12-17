set -eu

# utility functions
INFO() {
	printf "\e[104m\e[97m[INFO]\e[49m\e[39m %s\n" "$*"
}

WARNING() {
	>&2 printf "\e[101m\e[97m[WARNING]\e[49m\e[39m %s\n" "$*"
}

ERROR() {
	>&2 printf "\e[101m\e[97m[ERROR]\e[49m\e[39m %s\n" "$*"
}

# constants
CONTAINERD_ROOTLESS_SH="containerd-rootless.sh"
SYSTEMD_CONTAINERD_UNIT="containerd.service"
SYSTEMD_BUILDKIT_UNIT="buildkit.service"
SYSTEMD_FUSE_OVERLAYFS_UNIT="containerd-fuse-overlayfs.service"
SYSTEMD_STARGZ_UNIT="stargz-snapshotter.service"
SYSTEMD_IPFS_UNIT="ipfs-daemon.service"
SYSTEMD_BYPASS4NETNSD_UNIT="bypass4netnsd.service"

# global vars
ARG0="$0"
REALPATH0="$(realpath "$ARG0")"
BIN=""
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"


# run checks and also initialize global vars (BIN)
init() {
	id="$(id -u)"
	# User verification: deny running as root
	if [ "$id" = "0" ]; then
		ERROR "Refusing to install rootless containerd as the root user"
		exit 1
	fi

	# set BIN
	if ! BIN="$(command -v "$CONTAINERD_ROOTLESS_SH" 2>/dev/null)"; then
		ERROR "$CONTAINERD_ROOTLESS_SH needs to be present under \$PATH"
		exit 1
	fi
	BIN=$(dirname "$BIN")

	# detect systemd
	if ! command -v s6-svscan >/dev/null 2>&1; then
		ERROR "Needs systemd (systemctl --user)"
		exit 1
	fi

	# HOME verification
	if [ -z "${HOME:-}" ] || [ ! -d "$HOME" ]; then
		ERROR "HOME needs to be set"
		exit 1
	fi
	if [ ! -w "$HOME" ]; then
		ERROR "HOME needs to be writable"
		exit 1
	fi

	# Validate XDG_RUNTIME_DIR
	if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -w "$XDG_RUNTIME_DIR" ]; then
		ERROR "Aborting because but XDG_RUNTIME_DIR (\"$XDG_RUNTIME_DIR\") is not set, does not exist, or is not writable"
		ERROR "Hint: this could happen if you changed users with 'su' or 'sudo'. To work around this:"
		ERROR "- try again by first running with root privileges 'loginctl enable-linger <user>' where <user> is the unprivileged user and export XDG_RUNTIME_DIR to the value of RuntimePath as shown by 'loginctl show-user <user>'"
		ERROR "- or simply log back in as the desired unprivileged user (ssh works for remote machines, machinectl shell works for local machines)"
		ERROR "See also https://rootlesscontaine.rs/getting-started/common/login/ ."
		exit 1
	fi
}

install_systemd_unit() {
	unit="$1"
	unit_file="${XDG_CONFIG_HOME}/s6/${unit}"
	if [ -f "${unit_file}" ]; then
		WARNING "File already exists, skipping: ${unit_file}"
	else
		INFO "Creating \"${unit_file}\""
		mkdir -p "${service_dir}/run"
        mkdir -p "${service_dir}/finish"
		cat >"${unit_file}"
		systemctl --user daemon-reload
	fi
	if ! systemctl --user --no-pager status "${unit}" >/dev/null 2>&1; then
		INFO "Starting systemd unit \"${unit}\""
		(
			set -x
			if ! systemctl --user start "${unit}"; then
				set +x
				show_systemd_error "${unit}"
				exit 1
			fi
			sleep 3
		)
	fi
	(
		set -x
		if ! systemctl --user --no-pager --full status "${unit}"; then
			set +x
			show_systemd_error "${unit}"
			exit 1
		fi
		systemctl --user enable "${unit}"
	)
	INFO "Installed \"${unit}\" successfully."
	INFO "To control \"${unit}\", run: \`systemctl --user (start|stop|restart) ${unit}\`"
}

# CLI subcommand: "check"
cmd_entrypoint_check() {
	init
	INFO "Checking RootlessKit functionality"
	if ! rootlesskit \
		--net=slirp4netns \
		--disable-host-loopback \
		--copy-up=/etc --copy-up=/run --copy-up=/var/lib \
		true; then
		ERROR "RootlessKit failed, see the error messages and https://rootlesscontaine.rs/getting-started/common/ ."
		exit 1
	fi

	INFO "Checking cgroup v2"
	controllers="/sys/fs/cgroup/user.slice/user-${id}.slice/user@${id}.service/cgroup.controllers"
	if [ ! -f "${controllers}" ]; then
		WARNING "Enabling cgroup v2 is highly recommended, see https://rootlesscontaine.rs/getting-started/common/cgroup2/ "
	else
		for f in cpu memory pids; do
			if ! grep -qw "$f" "$controllers"; then
				WARNING "The cgroup v2 controller \"$f\" is not delegated for the current user (\"$controllers\"), see https://rootlesscontaine.rs/getting-started/common/cgroup2/"
			fi
		done
	fi

	INFO "Checking overlayfs"
	tmp=$(mktemp -d)
	mkdir -p "${tmp}/l" "${tmp}/u" "${tmp}/w" "${tmp}/m"
	if ! rootlesskit mount -t overlay -o lowerdir="${tmp}/l,upperdir=${tmp}/u,workdir=${tmp}/w" overlay "${tmp}/m"; then
		WARNING "Overlayfs is not enabled, consider installing fuse-overlayfs snapshotter (\`$0 install-fuse-overlayfs\`), " \
			"or see https://rootlesscontaine.rs/how-it-works/overlayfs/ to enable overlayfs."
	fi
	rm -rf "${tmp}"
	INFO "Requirements are satisfied"
}

# CLI subcommand: "install"
cmd_entrypoint_install() {
	init
	cmd_entrypoint_check
	cat <<-EOT | install_systemd_unit "${SYSTEMD_CONTAINERD_UNIT}"
		[Unit]
		Description=containerd (Rootless)
		Requires=dbus.socket

		[Service]
		Environment=PATH=$BIN:/sbin:/usr/sbin:$PATH
		Environment=CONTAINERD_ROOTLESS_ROOTLESSKIT_FLAGS=${CONTAINERD_ROOTLESS_ROOTLESSKIT_FLAGS:-}
		ExecStart=$BIN/${CONTAINERD_ROOTLESS_SH}
		ExecReload=/bin/kill -s HUP \$MAINPID
		TimeoutSec=0
		RestartSec=2
		Restart=always
		StartLimitBurst=3
		StartLimitInterval=60s
		LimitNOFILE=infinity
		LimitNPROC=infinity
		LimitCORE=infinity
		TasksMax=infinity
		Delegate=yes
		Type=simple
		KillMode=mixed

		[Install]
		WantedBy=default.target
	EOT
	systemctl --user daemon-reload
	INFO "To run \"${SYSTEMD_CONTAINERD_UNIT}\" on system startup automatically, run: \`sudo loginctl enable-linger $(id -un)\`"
	INFO "------------------------------------------------------------------------------------------"
	INFO "Use \`nerdctl\` to connect to the rootless containerd."
	INFO "You do NOT need to specify \$CONTAINERD_ADDRESS explicitly."
}


command=$(echo "${1:-}" | sed -e "s/-/_/g")
echo $command

if [ -z "$command" ]; then
	ERROR "No command was specified. Run with --help to see the usage. Maybe you want to run \`$ARG0 install\`?"
	exit 1
fi

if ! command -v "cmd_entrypoint_${command}" >/dev/null 2>&1; then
	ERROR "Unknown command: ${command}. Run with --help to see the usage."
	exit 1
fi


# main
shift
cmd_entrypoint_install "$@"