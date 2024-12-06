FROM kubeflownotebookswg/jupyter-scipy

USER root

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    sudo \
    gnupg \
    lsb-release \
    && sudo install -m 0755 -d /etc/apt/keyrings \
    && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && sudo chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
    && rm -rf /var/lib/apt/lists/*


RUN sudo usermod -aG docker $NB_USER

USER $NB_USER

EXPOSE 8888
