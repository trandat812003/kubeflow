FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN apt-get update
RUN apt-get install -y curl 
RUN apt-get install -y sudo 
RUN apt-get install -y lsb-release 
RUN apt-get install -y gnupg uidmap
RUN apt-get install -y ca-certificates 
RUN apt-get install -y golang-go make
RUN apt-get install -y iproute2
RUN apt-get install -y autoconf runc
RUN apt-get install -y libglib2.0-dev pkg-config libslirp-dev libcap-dev libseccomp-dev
RUN apt-get clean

RUN curl -sSL https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz -o containerd.tar.gz
RUN tar -C /usr/local -xvzf containerd.tar.gz

RUN echo "user.max_user_namespaces=28633" >> /etc/sysctl.d/userns.conf
RUN echo "kernel.unprivileged_userns_clone=1" >> /etc/sysctl.d/userns.conf
RUN sysctl --system

RUN mkdir -p /opt/cni/bin
COPY ./cni-plugins-linux-amd64-v0.8.3.tgz cni-plugins-linux-amd64-v0.8.3.tgz
RUN tar -xvf cni-plugins-linux-amd64-v0.8.3.tgz -C /opt/cni/bin/
RUN mkdir -p /etc/cni/net.d
COPY ./cni/10-bridge.conf /etc/cni/net.d/10-bridge.conf
COPY ./cni/99-loopback.conf /etc/cni/net.d/99-loopback.conf

USER jovyan

# RUN curl -o slirp4netns --fail -L https://github.com/rootless-containers/slirp4netns/releases/download/v1.3.1/slirp4netns-x86_64
# RUN chmod +x slirp4netns

RUN mkdir -p ~/bin
RUN curl -fsSL https://github.com/rootless-containers/rootlesskit/releases/download/v2.3.1/rootlesskit-x86_64.tar.gz | tar Cxzv ~/bin
RUN git clone https://github.com/rootless-containers/slirp4netns /home/jovyan/slirp4netns
WORKDIR /home/jovyan/slirp4netns
RUN ./autogen.sh && ./configure && make
RUN cp slirp4netns ~/bin

WORKDIR /home/jovyan

ENV PATH="$HOME/bin:$PATH"
ENV PATH=$PATH:/usr/sbin
RUN echo 'alias rootlesskit="~/bin/rootlesskit"' >> ~/.bashrc

COPY ./config.toml /home/jovyan/config.toml

EXPOSE 8888
