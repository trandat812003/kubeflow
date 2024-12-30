FROM nvcr.io/nvidia/tritonserver:23.09-py3 AS triton

# RUN python3 -m pip install --upgrade pip
RUN apt-get update && apt-get install -y libb64-0d
RUN pip install torch 
RUN pip install transformers 
RUN pip install numpy 
RUN pip install pydub 
RUN pip install torchaudio 
RUN pip install onnx
RUN pip install tritonclient[all]
RUN pip install requests
RUN pip install notebook
RUN git clone https://github.com/triton-inference-server/python_backend -b r23.10


FROM kubeflownotebookswg/jupyter-scipy AS notebook

# COPY --from=triton /usr/local /usr/local
# COPY --from=triton /opt /opt
# COPY --from=triton /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
# COPY --from=triton /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=triton / /
COPY ./models /models

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
ENV tritonserver=/opt/tritonserver/bin/tritonserver

EXPOSE 8000
EXPOSE 8001
EXPOSE 8002
EXPOSE 8888

# CMD ["tritonserver", "--model-repository=/models", "--log-format=default", "--log-file=/opt/tritonserver/logfile.log"] 
# CMD ["tritonserver", "--model-repository=/models", "--cache-config=local,size=1000048576", "--log-verbose=1"]   
# CMD ["tritonserver", "--model-repository=/models", "--log-format=default", "--log-file=/opt/tritonserver/logfile.log"]   
# CMD ["tritonserver", "--model-repository=/models", "--log-verbose=2"]
# CMD ["tritonserver", "--model-repository=/models"]  
# CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
# jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
