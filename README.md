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
docker build -t jupyter-notebook .
```

```
docker run -it --privileged --name test --security-opt seccomp=unconfined --security-opt apparmor=unconfined --rm -p 8888:8888 -v /run/containerd/containerd.sock:/run/containerd/containerd.sock jupyter-notebook
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
rootlesskit --net=slirp4netns --copy-up=/etc --copy-up=/run --state-dir=/home/jovyan/rootlesskit-containerd sh -c "rm -f /run/containerd; exec containerd -c /home/jovyan/config.toml"
```

```
unshare --user --map-root-user --net --mount

echo $$ > /tmp/pid

echo "user.max_user_namespaces=28633"

echo "kernel.unprivileged_userns_clone=1"

sudo sysctl --system
```