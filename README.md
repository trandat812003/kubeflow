# kubeflow

```
kubectl get notebooks -n kubeflow-user-example-com
```

```
kubectl create -f notebook.yaml
```

```
kubectl get notebook t3 -n kubeflow-user-example-com -o yaml > t3-notebook.yaml
```

```
sudo sysctl fs.inotify.max_user_instances=2280
```

```
sudo sysctl fs.inotify.max_user_watches=1255360
```