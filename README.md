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
docker build -t test .
```

```
docker run -it --privileged --name test --security-opt seccomp=unconfined --security-opt apparmor=unconfined --rm -p 8888:8888 -v /run/containerd/containerd.sock:/run/containerd/containerd.sock -v /lib/modules:/lib/modules test
```

```
docker exec -it test bash
```

```
rootlesskit --net=slirp4netns --disable-host-loopback --copy-up=/etc --copy-up=/run --copy-up=/var/lib true
containerd-rootless.sh
```

```
nerdctl --snapshotter=native pull hello-world
```

```
nerdctl --snapshotter=native run hello-world
```