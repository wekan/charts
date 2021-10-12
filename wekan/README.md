# WeKan ®

## Open Source and Free software collaborative kanban board application

[Wekan](https://wekan.github.io/) is an completely Open Source and Free software collaborative kanban board application with MIT license.

## QuickStart

```bash
$ helm repo add wekan https://wekan.github.io/charts/
$ helm repo update
$ helm install foo wekan/wekan --namespace bar
```

## Introduction

This chart deploys Wekan

## Prerequisites

- Kubernetes 1.4+
- Mongodb database

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install my-release wekan/wekan --namespace bar
```

> **Tip**: List all releases using `helm list`

In order to deploy this chart under Kubernetes 1.9+, the `kubeMeta.deploymentApiVersion` MUST be set to "apps/v1".

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The configurable parameters of the Wekan chart and
their descriptions can be seen in `values.yaml`. The [full compose file](https://github.com/wekan/wekan/blob/master/docker-compose.yml) contains more information about Environments variables you can set in docker.

> **Tip**: You can use the default [values.yaml](values.yaml)

Here are the most common:

|             Parameter               |            Description              |                    Default                |
|-------------------------------------|-------------------------------------|-------------------------------------------|
| `replicaCount`                      | Number of replicas                  | `1`                                       |
| `image.repository`                  | The image to run                    | `quay.io/wekan/wekan`                     |
| `image.tag`                         | The image tag to pull               | `vX.XX`                                   |
| `image.pullPolicy`                  | Image pull policy                   | `IfNotPresent`                            |
| `image.pullSecrets`                 | Specify image pull secrets          | `nil`                                     |
| `service.type`                      | Type of Service                     | `ClusterIP`                               |
| `service.port`                      | Port for kubernetes service         | `80`                                      |
| `ingress.enabled`                   | Enable ingress                      | `false`                                   |
| `ingress.annotations`               | Annotations for ingress             | `{}`                                      |
| `ingress.hosts[0].host`             | Ingress host                        | `"chart-example.local"`                   |
| `ingress.hosts[0].paths`            | Ingress paths                       | `[]`                                      |
| `ingress.tls`                       | Ingress tls settings                | `[]`                                      |
| `resources`                         | Kubernetes ressources options       | `{}`                                      |
| `podSecurityContext`                | Pod security context settings       | `{}`                                      |
| `securityContext`                   | Security context settings           | `{}`                                      |
| `podAnnotations`                    | Pod annotations                     | `[]`                                      |
| `nodeSelector`                      | Node selector                       | `{}`                                      |
| `tolerations`                       | Tolerations                         | `[]`                                      |
| `affinity`                          | Affinity                            | `{}`                                      |
| `wekan.env.MONGO_URL`               | URL to the MongoDB host             | `mongodb://wekandb:27017/wekan`           |
| `wekan.env.ROOT_URL`                | URL to your Wekan instance          | `http://localhost`                        |

# Helm Chart for Wekan

## Features

o Uses a MongoDB replica set by default - this allows fault-tolerant
  and scalable MongoDB deployment (or just set the replicas to 1 for
  a single server install)

o Optional Horizontal Pod Autoscaler (HPA), so that your Wekan pods
  will scale automatically with increased CPU load.

## The configurable values (values.yaml)

Scaling Wekan:

```yaml
## Configuration for wekan component
##

replicaCount: 1
```
**replicaCount** Will set the initial number of replicas for the Wekan pod (and container)

```yaml
## Configure an horizontal pod autoscaler
##
autoscaling:
  enabled: true
  config:
    minReplicas: 1
    maxReplicas: 16
    ## Note: when setting this, a `resources.request.cpu` is required. You
    ## likely want to set it to `1` or some lower value.
    ##
    targetCPUUtilizationPercentage: 80
```
This section (if *enabled* is set to **true**) will enable the Kubernetes Horizontal Pod Autoscaler (HPA).

**minReplicas:** this is the minimum number of pods to scale down to (We recommend setting this to the same value as **replicaCount**).

**maxReplicas:** this is the maximum number of pods to scale up to.

**targetCPUUtilizationPercentage:** This is the CPU at which the HPA will scale-out the number of Wekan pods.

```yaml
mongodb-replicaset:
  enabled: true
  replicas: 3
  replicaSetName: rs0
  securityContext:
    runAsUser: 1000
    fsGroup: 1000
    runAsNonRoot: true
```

This section controls the scale of the MongoDB redundant Replica Set.

**replicas:** This is the number of MongoDB instances to include in the set. You can set this to 1 for a single server - this will still allow you to scale-up later with a helm upgrade.

### Install OCP route
If you use this chart to deploy Wekan on an OCP cluster, you can create route instead of ingress with following command:

``` bash
$ helm template --set route.enabled=true,ingress.enabled=false values.yaml . | oc apply -f-
```
