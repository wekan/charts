# WeKan ® - Open Source kanban

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm repo add wekan https://wekan.github.io/charts
helm install my-release wekan/wekan
```

These commands deploy Wekan on the Kubernetes cluster in the default configuration.

Tip: List all releases using `helm list`

For all available values see `helm show values wekan/wekan`.

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```bash
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Features

* Ships **FerretDB** as its database (`ghcr.io/wekan/ferretdb`), installed by
  this chart itself as one StatefulSet and one ClusterIP Service. This is what
  WeKan itself runs on ([charts#55](https://github.com/wekan/charts/issues/55)),
  and it is why the connection URL cannot be wrong any more
  ([charts#54](https://github.com/wekan/charts/issues/54)): the Service the chart
  connects to is the Service the chart creates.

* Works with a database you run yourself instead - a MongoDB, a FerretDB
  elsewhere, or a managed service - via `externalDatabase.url`.

* Optional Horizontal Pod Autoscaler (HPA), so that your Wekan pods
  will scale automatically with increased CPU load.

## The configurable values (values.yaml)

Scaling Wekan:

```yaml
## Configuration for wekan component
##

replicaCount: 1
```

**replicaCount** will set the initial number of replicas for the Wekan pod
(and container)

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

This section (if *enabled* is set to **true**) will enable the Kubernetes
Horizontal Pod Autoscaler (HPA).

**minReplicas:** this is the minimum number of pods to scale down to
(We recommend setting this to the same value as **replicaCount**).

**maxReplicas:** this is the maximum number of pods to scale up to.

**targetCPUUtilizationPercentage:** This is the CPU at which the HPA will
scale-out the number of Wekan pods.

```yaml
# Optional custom labels for the pods created by the deployment.
podLabels: {}

# Optional custom annotations for the pods created by the deployment.
podAnnotations: {}
```

**podLabels:** These are custom labels that will be applied to the Wekan pods.

**podAnnotations:** These are custom annotations that will be applied to the Wekan pods.
This can be useful for integrating with monitoring systems, service meshes, or other Kubernetes tools.

```yaml
ferretdb:
  # Optional custom annotations for the FerretDB pod
  podAnnotations: {}
```

**podAnnotations:** These are custom annotations that will be applied to the FerretDB pod.

### The database

```yaml
ferretdb:
  enabled: true
  image:
    repository: ghcr.io/wekan/ferretdb
    tag: latest
  storage:
    size: 8Gi
    accessMode: ReadWriteOnce
    # storageClassName: ""
    # existingClaim: ""
```

FerretDB runs as **one** replica, and that is not a limitation to work around:
FerretDB v1 on SQLite is a single writer over one data directory, so a second
pod would be a second process writing the same file. WeKan itself scales
horizontally with `replicaCount` and the HPA above.

The image is published to three registries by
[wekan/FerretDB's docker workflow](https://github.com/wekan/FerretDB/blob/main-v1/.github/workflows/docker.yml)
— `ghcr.io/wekan/ferretdb`, `quay.io/wekan/ferretdb` and `wekanteam/ferretdb`
(Docker Hub) — so `ferretdb.image.repository` can point at whichever one your
cluster can reach, or at your own mirror.

### Using your own database instead

```yaml
ferretdb:
  enabled: false
externalDatabase:
  url: "mongodb://mongodb.example.com:27017/wekan"
```

`directConnection=true` is appended for you unless your URL already sets it.
That parameter is required rather than decorative
([wekan/wekan#6582](https://github.com/wekan/wekan/issues/6582)): without it the
MongoDB driver performs replica-set discovery, drops the host you wrote and dials
the address the server advertises — which for FerretDB is `0.0.0.0:27017`, and
inside the WeKan pod that is the WeKan pod.

### Upgrading from the MongoDB versions of this chart (≤ 10.85.0)

Nothing is deleted by the upgrade: the MongoDB StatefulSet and its
PersistentVolumeClaim from the old dependency are left where they are. The
shortest route is to keep using them, by pointing the chart at the Service that
chart really created:

```yaml
ferretdb:
  enabled: false
externalDatabase:
  url: "mongodb://<release>-mongodb:27017/wekan"
```

To move onto FerretDB instead, `mongodump` from MongoDB and `mongorestore` into
FerretDB — both speak the MongoDB wire protocol, so the tools work unchanged.

### Install OCP route

If you use this chart to deploy Wekan on an OCP cluster, you can create route
instead of ingress with following command:

```bash
helm template --set route.enabled=true,ingress.enabled=false values.yaml . | \
  oc apply -f-
```

# Install with Local Image Registry

To utilize a local Image Registry, configure the following values to point to your local registry:

```yaml
image:
  repository: ghcr.io/wekan/wekan
init:
  image:
    repository: docker.io/busybox
test:
  image:
    repository: docker.io/busybox
```

Additionally, point the database image at your own registry:

```yaml
ferretdb:
  image:
    repository: "<your mirror>/wekan/ferretdb"
```

This setup will ensure that all images are pulled from your specified local registry, optimizing performance and reliability for your deployment environment.
