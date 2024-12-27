FROM nvcr.io/nvidia/tritonserver:24.12-trtllm-python-py3

RUN python3 -m pip install --upgrade pip
RUN apt-get update && apt-get install -y libb64-0d
RUN pip install torch 
RUN pip install transformers 
RUN pip install numpy 
RUN pip install pydub 
RUN pip install torchaudio 
RUN pip install onnx
RUN pip install tritonclient[all]
RUN pip install requests
RUN git clone https://github.com/triton-inference-server/python_backend -b r23.10


COPY ./models /models

# CMD ["tritonserver", "--model-repository=/models", "--log-format=default", "--log-file=/opt/tritonserver/logfile.log"] 
# CMD ["tritonserver", "--model-repository=/models", "--cache-config=local,size=1000048576", "--log-verbose=1"]   
# CMD ["tritonserver", "--model-repository=/models", "--log-format=default", "--log-file=/opt/tritonserver/logfile.log"]   
# CMD ["tritonserver", "--model-repository=/models", "--log-verbose=2"]
CMD ["tritonserver", "--model-repository=/models"]  
