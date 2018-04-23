#!/bin/bash

su ubuntu -c "kubectl rollout status deployment/wordpress"
#Count how many pods are running
runningPods=$(su ubuntu -c "kubectl get pods --field-selector=status.phase=Running --selector=run=wordpress | grep -c Running")

exitValue=0
if [ $runningPods != "0" ]
then
  echo "successfully deployed pods"
else
  echo "error: pods are not in running state"
  exitValue=1
fi

exit $exitValue