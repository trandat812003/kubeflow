FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN apt-get update
RUN apt-get install -y curl 
RUN apt-get install -y sudo systemd
RUN apt-get install -y lsb-release 
RUN apt-get install -y gnupg uidmap
RUN apt-get install -y ca-certificates iproute2
RUN apt-get clean

RUN curl -sSL https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz -o containerd.tar.gz
RUN tar -C /usr/local -xvzf containerd.tar.gz

RUN wget https://github.com/containerd/nerdctl/releases/download/v2.0.2/nerdctl-full-2.0.2-linux-amd64.tar.gz
RUN tar Cxzvvf /usr/local nerdctl-full-2.0.2-linux-amd64.tar.gz

USER jovyan

# COPY ./containerd-rootless-setuptool.sh /usr/local/bin/containerd-rootless-setuptool.sh
# COPY ./containerd-rootless.sh /usr/local/bin/containerd-rootless.sh

WORKDIR /home/jovyan/
COPY ./test.sh test.sh


# RUN containerd-rootless-setuptool.sh install

ENV XDG_RUNTIME_DIR=/tmp/runtime-jovyan
RUN mkdir -p /tmp/runtime-jovyan

USER root

RUN chmod +x /usr/local/bin/containerd-rootless-setuptool.sh

USER jovyan


EXPOSE 8888
