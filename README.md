#

```
docker run --gpus=all -p 8888:8888 -p 8000:8000 -p 8001:8001 -p 8002:8002 --rm -it test bash
```

```
/opt/nvidia/nvidia_entrypoint.sh jupyter lab --notebook-dir='/workspace' --ip=0.0.0.0 --no-browser --allow-root --port=8888 --ServerApp.token='' --ServerApp.password='' --NotebookApp.token='' --NotebookApp.password='' --ServerApp.allow_origin='*' --ServerApp.authenticate_prometheus=False --ServerApp.base_url="$(NB_PREFIX)" --NotebookApp.base_url="$(NB_PREFIX)"
```

```
/opt/tritonserver/bin/tritonserver --model-repository=/workspace/models
```

```
# kubectl get svc triton-notebook-service -n kubeflow-user-example-com

# kubectl get nodes -o wide

kubectl port-forward svc/triton-notebook-service 8000:8000 8001:8001 8002:8002 -n kubeflow-user-example-com
```

```
curl -X GET "http://localhost:8000/v2/models/test/versions/1/stats"
```

```
# CMD ["tritonserver", "--model-repository=/models", "--log-format=default", "--log-file=/opt/tritonserver/logfile.log"] 
# CMD ["tritonserver", "--model-repository=/models", "--cache-config=local,size=1000048576", "--log-verbose=1"]   
# CMD ["tritonserver", "--model-repository=/models", "--log-format=default", "--log-file=/opt/tritonserver/logfile.log"]   
# CMD ["tritonserver", "--model-repository=/models", "--log-verbose=2"]
# CMD ["tritonserver", "--model-repository=/models"]  
```