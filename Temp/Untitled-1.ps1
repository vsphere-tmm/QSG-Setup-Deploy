#!/bin/bash

########################
# include the magic
########################
. /$HOME/demo-magic.sh

pe "cat standard-vsphere-pod.yaml"

pe "kubectl create -f standard-vsphere-pod.yaml"

pe "kubectl logs standard-vsphere-pod -n my-podvm-ns"
