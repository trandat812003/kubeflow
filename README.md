#

```
docker run -p 8888:8888 -p 8000:8000 -p 8001:8001 -p 8002:8002 --rm -it test bash
```

```
/opt/tritonserver/bin/tritonserver --model-repository=/home/jovyan/models
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