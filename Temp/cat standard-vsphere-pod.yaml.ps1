cat standard-vsphere-pod.yaml

kubectl create -f standard-vsphere-pod.yaml

kubectl logs standard-vsphere-pod -n my-podvm-ns

kubectl delete -f standard-vsphere-pod.yaml
