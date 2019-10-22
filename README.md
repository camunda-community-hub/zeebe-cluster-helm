# Zeebe Cluster Helm Chart

This functionality is in beta and is subject to change. The design and code is less mature than official GA features and is being provided as-is with no warranties. Beta features are not subject to the support SLA of official GA features.

## Requirements

* [Helm](https://helm.sh/) >= 2.8.0
* Kubernetes >= 1.8
* Minimum cluster requirements include the following to run this chart with default settings. All of these settings are configurable.
  * Three Kubernetes nodes to respect the default "hard" affinity settings
  * 1GB of RAM for the JVM heap

## Usage notes and getting started

## Installing

* Add the official zeebe helm charts repo
  ```
  helm repo add zeebe https://helm.zeebe.io
  ```
* Install it
  ```
  helm install --name zeebe-cluster zeebe/zeebe-cluster
  ```

 ## Configuration
  | Parameter                     | Description                                                                                                                                                                                                                                                                                                                | Default                                                                                                                   |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `kibana.enabled`                 | Enable Kibana deployment as part of the Zeebe Cluster                                                                                                                                | `false`                                                                                                           |
| `clusterSize`                 | Set the Zeebe Cluster Size and the number of replicas of the replica set                                                                                                                                | `3`   
| `partitionCount`                 | Set the Zeebe Cluster partition count                                                                                                                                | `3`   
| `replicationFactor`                 | Set the Zeebe Cluster replication factor                                                                                                                                | `3`   
| `cpuThreadCount`                 | Set the Zeebe Cluster CPU thread count                                                                                                                                | `2`   
| `ioThreadCount`                 | Set the Zeebe Cluster IO thread count                                                                                                                                | `2`  
