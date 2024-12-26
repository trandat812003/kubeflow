FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirror.nus.edu.sg/ubuntu|g' /etc/apt/sources.list
RUN sed -i 's|http://mirror.nus.edu.sg/ubuntu|http://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y curl lsb-release gnupg ca-certificates net-tools
RUN apt-get install -y linux-generic kmod slirp4netns fuse-overlayfs uidmap iptables iproute2
RUN apt-get install -y util-linux
RUN apt-get clean

RUN curl -sSL https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz -o containerd.tar.gz
RUN tar -C /usr/local -xvzf containerd.tar.gz

RUN wget https://github.com/containerd/nerdctl/releases/download/v2.0.2/nerdctl-full-2.0.2-linux-amd64.tar.gz
RUN tar Cxzvvf /usr/local nerdctl-full-2.0.2-linux-amd64.tar.gz

RUN chmod +x /usr/local/bin/containerd-rootless.sh
RUN chmod +x /usr/bin/nsenter

RUN sysctl -w kernel.unprivileged_userns_clone=1

USER jovyan

ENV XDG_RUNTIME_DIR=/tmp/runtime-jovyan
ENV CONTAINERD_SNAPSHOTTER=native
RUN mkdir -p /tmp/runtime-jovyan

WORKDIR /home/jovyan/

EXPOSE 8888
