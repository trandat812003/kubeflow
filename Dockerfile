FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN apt-get update
RUN apt-get install -y curl sudo lsb-release gnupg ca-certificates
RUN apt-get clean

RUN groupadd tmpusers \
    && usermod -aG tmpusers jovyan \
    && chown root:tmpusers /tmp \
    && chmod 1777 /tmp  

RUN curl -sSL https://github.com/containerd/containerd/releases/download/v1.6.12/containerd-1.6.12-linux-amd64.tar.gz -o containerd.tar.gz
RUN tar -C /usr/local -xvzf containerd.tar.gz
RUN mkdir -p /etc/containerd
RUN touch /etc/containerd/config.toml

COPY ./config.toml /etc/containerd/config.toml

RUN usermod -aG root jovyan

USER $NB_USER

EXPOSE 8888

CMD ["/usr/local/bin/containerd"]