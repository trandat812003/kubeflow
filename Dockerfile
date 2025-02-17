ARG TRITON_VERSION=24.12

FROM nvcr.io/nvidia/tritonserver:${TRITON_VERSION}-py3

ARG TRITON_VERSION
ARG NB_PREFIX
ENV NB_PREFIX=${NB_PREFIX}

RUN git clone https://github.com/triton-inference-server/python_backend -b r${TRITON_VERSION}

RUN apt-get update && apt-get install -y \
    portaudio19-dev \
    libsndfile1 \
    ffmpeg 

RUN curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null 
RUN echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list 
RUN apt update && apt install -y ngrok

COPY ./requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

EXPOSE 8000 8001 8002

# ENTRYPOINT [ "jupyter", "lab", "--notebook-dir=", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--port=8888", "--ServerApp.token=", "--ServerApp.password=", "--NotebookApp.token=", "--NotebookApp.password=", "--ServerApp.allow_origin=*", "--ServerApp.authenticate_prometheus=False", "--ServerApp.base_url=${NB_PREFIX}", "--NotebookApp.base_url=${NB_PREFIX}" ]
ENTRYPOINT ["sh", "-c", "jupyter lab --notebook-dir=/ --ip=0.0.0.0 --no-browser --allow-root --port=8888 --ServerApp.token='' --ServerApp.password='' --NotebookApp.token='' --NotebookApp.password='' --ServerApp.allow_origin='*' --ServerApp.authenticate_prometheus=False --ServerApp.base_url=$NB_PREFIX --NotebookApp.base_url=$NB_PREFIX"]

