FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN apt-get update
RUN apt-get install -y curl 
RUN apt-get install -y sudo 
RUN apt-get install -y lsb-release 
RUN apt-get install -y gnupg 
RUN apt-get install -y ca-certificates 
RUN apt-get install -y systemd
RUN apt-get clean

RUN curl -sSL https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz -o containerd.tar.gz
RUN tar -C /usr/local -xvzf containerd.tar.gz

# RUN wget https://github.com/containerd/nerdctl/releases/download/v2.0.2/nerdctl-full-2.0.2-linux-amd64.tar.gz
# RUN tar Cxzvvf /usr/local nerdctl-full-2.0.2-linux-amd64.tar.gz

USER jovyan

RUN curl -fsSL https://github.com/rootless-containers/rootlesskit/releases/download/v2.3.1/rootlesskit-x86_64.tar.gz -o /usr/local/bin/rootlesskit
RUN chmod +x /usr/local/bin/rootlesskit

EXPOSE 8888
