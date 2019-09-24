#!/bin/bash

if [[ -z $NODE_TIMEOUT ]]
then
	NODE_TIMEOUT=360
fi
echo "Node timeout: $NODE_TIMEOUT"

if [[ -z $AUTO_UNCORDON ]]
then
	AUTO_UNCORDON=true
fi
echo "Auto uncordon node on recovery is $AUTO_UNCORDON"

touch ~/drained_nodes

while true
do
	if curl -v --silent http://localhost:4040/ 2>&1 | grep $HOSTNAME
	then
		echo "Leader"
		for node in $(kubectl get nodes --no-headers --output=name)
		do
			echo "#########################################################"
			echo "Checking $node"
			current_status="$(kubectl get --no-headers $node | awk '{print $2}')"
			##echo "Current node status: $current_status"
			if [[ "$current_status" == "Ready" ]]
			then
				echo "$node is ready"
				if cat ~/drained_nodes | grep -x $node
				then
					echo "$node has recovered"
					cat ~/drained_nodes | grep -v -x $node > ~/drained_nodes.tmp
					mv ~/drained_nodes.tmp ~/drained_nodes
					if [[ "$AUTO_UNCORDON" == "true" ]]
					then
						echo "uncordon $node"
						kubectl uncordon $node
					fi
				fi

			else
				if cat ~/drained_nodes | grep -x $node
				then
					echo "$node is ready drained, skipping..."
				else
					echo "$node in Not ready, rechecking..."
					count=0
					while true
					do
						current_status="$(kubectl get --no-headers $node | awk '{print $2}')"
						if [[ ! "$current_status" == "Ready" ]]
						then
							echo "Sleeping for $count seconds"
							sleep 1
							count=$((count+1))
						else
							echo "$node is now ready"
							cat ~/drained_nodes | grep -v -x $node > ~/drained_nodes.tmp
			                                mv ~/drained_nodes.tmp ~/drained_nodes
							break
						fi
						if [ $count -gt $NODE_TIMEOUT ]
						then
							echo "$node has been down for greater than 5Mins, assuming node is down for good."
							echo "Starting drain of node..."
							kubectl drain $node --ignore-daemonsets --force
							echo $node >> ~/drained_nodes
							break
						fi
					done
				fi
			fi
			echo "#########################################################"
		done
	else
		echo "Standby"
	fi
	echo "Sleeping for 5s before rechecking..."
	sleep 5
done
