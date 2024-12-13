FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN apt-get update
RUN apt-get install -y curl 
RUN apt-get install -y sudo 
RUN apt-get install -y lsb-release 
RUN apt-get install -y gnupg 
RUN apt-get install -y ca-certificates 
RUN apt-get install -y slirp4netns 
RUN apt-get install -y uidmap 
RUN apt-get install -y procps
RUN apt-get install -y iproute2 
RUN apt-get install -y iputils-ping
RUN apt-get install -y containernetworking-plugins
RUN apt-get install -y runc
RUN apt-get clean

RUN curl -sSL https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz -o containerd.tar.gz
RUN tar -C /usr/local -xvzf containerd.tar.gz

RUN mkdir -p ~/bin
RUN curl -sSL https://github.com/rootless-containers/rootlesskit/releases/download/v2.3.1/rootlesskit-x86_64.tar.gz | tar Cxzv ~/bin

# COPY ./containerd /home/jovyan/containerd
# RUN cd /home/jovyan/containerd/script/setup
# RUN bash ./install-cni

# USER root
RUN sysctl -w kernel.unprivileged_userns_clone=1

RUN chmod u+s /usr/bin/newuidmap && chmod u+s /usr/bin/newgidmap

USER $NB_USER

RUN mkdir -p ~/rootlesskit-containerd
RUN echo 'alias rootlesskit="~/bin/rootlesskit"' >> ~/.bashrc

COPY ./config.toml /home/jovyan/config.toml
COPY ./Dockerfile /home/jovyan/Dockerfile

EXPOSE 8888
