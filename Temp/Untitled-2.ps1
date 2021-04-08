#!/bin/bash

########################
# include the magic
########################
. /$HOME/demo-magic.sh

pe "cat confidential-vsphere-pod.yaml"

pe "kubectl create -f confidential-vsphere-pod.yaml"

pe "kubectl logs confidential-vsphere-pod -n my-podvm-ns"
