# Drain-Node-On-Crash
This app is designed to automatically Drain a node after a crash where the node fails to recover after 5mins.

## Install
```
git clone
cd drain-node-on-crash
kubectl apply -f .
```

## Default settings
NODE_TIMEOUT = 360  (seconds)

AUTO_UNCORDON = true (This setting will automatically uncordon a node that was drained by the script. NOTE: Nodes that have cordon outside this app will not be changed.)
