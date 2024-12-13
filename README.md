# kubeflow

```
kubectl get notebooks -n kubeflow
```

```
kubectl create -f notebook.yaml
```

```
kubectl get notebook t3 -n kubeflow -o yaml > t3-notebook.yaml
```

```
sudo sysctl fs.inotify.max_user_instances=2280
```

```
sudo sysctl fs.inotify.max_user_watches=1255360
```

# containerd

```
docker run -it --privileged --name test --security-opt seccomp=unconfined --security-opt apparmor=unconfined --rm -p 8888:8888 -v /run/containerd/containerd.sock:/run/containerd/containerd.sock jupyter-notebook
```

```
docker build -t jupyter-notebook .
```

```
docker exec -it test bash
```

```
ctr image pull docker.io/library/hello-world:latest
```

```
ctr run --rm docker.io/library/hello-world:latest hello-world-container
```

```
rootlesskit --net=slirp4netns --copy-up=/home/jovyan/ --copy-up=/run --copy-up=/etc --state-dir=/home/jovyan/rootlesskit-containerd sh -c "rm -f /run/containerd; exec containerd -c /home/jovyan/config.toml"
```

```
nsenter -U --preserve-credentials -m -n -t $(cat /home/jovyan/rootlesskit-containerd/child_pid)
```

```
export CONTAINERD_ADDRESS=/run/containerd/containerd.sock
```

```
export CONTAINERD_SNAPSHOTTER=native
```
