FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN apt-get update
RUN apt-get install -y curl sudo lsb-release gnupg ca-certificates
RUN apt-get clean

RUN curl -sSL https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz -o containerd.tar.gz
RUN tar -C /usr/local -xvzf containerd.tar.gz
RUN mkdir -p /etc/containerd
RUN touch /etc/containerd/config.toml

COPY ./config.toml /etc/containerd/config.toml
COPY ./Dockerfile /Dockerfile

RUN curl -sSL https://github.com/containerd/nerdctl/releases/download/v2.0.1/nerdctl-2.0.1-linux-arm64.tar.gz -o nerdctl.tar.gz
RUN tar -C /usr/local/bin -xvzf nerdctl.tar.gz
USER jovyan
RUN containerd-rootless-setuptool.sh install

# USER root
# RUN usermod -aG root jovyan

USER $NB_USER

EXPOSE 8888
