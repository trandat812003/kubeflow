FROM nvcr.io/nvidia/tritonserver:23.09-py3 AS triton
FROM nvcr.io/nvidia/pytorch:23.09-py3 AS notebook

USER root
# RUN chmod -R 777 /var/lib/apt/lists/ 
RUN python3 -m pip install --upgrade pip
RUN apt-get update && apt-get install -y libb64-0d
RUN pip install torch 
# RUN pip install transformers 
RUN pip install numpy 
# RUN pip install pydub 
# RUN pip install torchaudio 
# RUN pip install onnx
RUN pip install tritonclient[all]
RUN pip install requests

COPY --from=triton /opt/tritonserver /opt/tritonserver
COPY --from=triton /usr/src/tensorrt /usr/src/tensorrt
COPY --from=triton /lib/ /lib/

RUN git clone https://github.com/triton-inference-server/python_backend -b r23.10 /opt/tritonserver/python_backend

EXPOSE 8000
EXPOSE 8001
EXPOSE 8002
EXPOSE 8888
