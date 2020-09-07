#!/bin/bash

function check_node {
  current_status=`kubectl get node --no-headers "$1" |awk '{print $2}'`
  if [[ "$current_status" == "Ready" ]] || [[ "$current_status" == "Ready,SchedulingDisabled" ]]
  then
    return 0
  else
    return 1
  fi
}

if [[ -z $nodeTimeout ]]
then
  nodeTimeout=60
fi
echo "nodeTimeout: $nodeTimeout"

echo "nodeName: $nodeName"
if [[ -z "$nodeName" ]]
then
  echo "Missing nodeName"
  exit 1
fi

echo "Verifing Docker CLI access..."
if ! docker info
then
  echo "Problem accessing Docker CLI"
  exit 2
fi

while true;
do
  echo "Checking node status..."
  if check_node $nodeName
  then
    echo "Node is ready"
  else
    echo "Node is Not ready, rechecking..."
    count=0
    while true
    do
      if ! check_node $nodeName
      then
        echo "Sleeping for $count seconds"
        sleep 1
        count=$((count+1))
      else
        echo "Node is now ready"
        break
      fi
      if [ $count -gt $nodeTimeout ]
      then
        echo "Node has been down for greater then $nodeTimeout seconds, assuming node is down"
        echo "Attempting node recovery"
        echo "Restarting kubelet"
        docker restart kubelet
        echo "Sleeping..."
        sleep 15
        if check_node $nodeName
        then
          echo "Node has recovered"
          break
        fi
      fi
    done
  fi
done
