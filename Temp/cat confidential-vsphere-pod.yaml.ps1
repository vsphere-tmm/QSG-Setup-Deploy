cat confidential-vsphere-pod.yaml

kubectl create -f confidential-vsphere-pod.yaml

kubectl logs confidential-vsphere-pod -n my-podvm-ns

kubectl delete -f confidential-vsphere-pod.yaml


