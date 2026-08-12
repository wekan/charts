{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "wekan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wekan.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified name for the wekan data app.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "wekan.localdata.fullname" -}}
{{- if .Values.localdata.fullnameOverride -}}
{{- .Values.localdata.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-localdata" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-localdata" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wekan.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use for the api component
*/}}
{{- define "wekan.serviceAccountName" -}}
{{- if .Values.serviceAccounts.create -}}
    {{ default (include "wekan.fullname" .) .Values.serviceAccounts.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.name }}
{{- end -}}
{{- end -}}

{{/*
The FerretDB Service name. It is THIS chart's, which is the point of charts#54:
the old helper guessed at another chart's naming - Bitnami's per-pod
`<release>-mongodb-0.<release>-mongodb-headless` - while the chart WeKan actually
depended on (groundhog2k) called its services `<release>-mongodb` and
`<release>-mongodb-internal`. The name WeKan dialled therefore did not exist:

  MongoNetworkError: getaddrinfo ENOTFOUND wekan-mongodb-0.wekan-mongodb

There is nothing to guess now. templates/ferretdb-service.yaml creates a Service
with exactly this name.
*/}}
{{- define "wekan.ferretdb.fullname" -}}
{{- if .Values.ferretdb.fullnameOverride -}}
{{- .Values.ferretdb.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-ferretdb" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
The database URL WeKan connects to.

  ferretdb.enabled          the FerretDB this chart installs
  externalDatabase.url      whatever the admin runs themselves (MongoDB 7,
                            FerretDB elsewhere, a managed service)

`directConnection=true` is REQUIRED and not decoration (wekan/wekan#6582). A
FerretDB started with a replica-set name advertises, in its handshake, a replica
set whose only member is its own LISTEN address - 0.0.0.0:27017. Without
directConnection the MongoDB driver performs replica-set discovery: it DROPS the
host written here and dials the advertised 0.0.0.0:27017, which inside the WeKan
pod is the WeKan pod, and the connection dies as

  MongoServerSelectionError: connect ECONNREFUSED 0.0.0.0:27017

directConnection=true keeps the driver on the host this URL names. It is appended
to a user-supplied URL as well, unless that URL already sets it - a URL that
worked before is left exactly as it was.

The old `mongodb.url` value is still honoured, so a chart upgrade does not lose
somebody's external database.
*/}}
{{- define "mongodb.url" -}}
{{- $external := "" -}}
{{- if .Values.externalDatabase -}}
  {{- $external = default "" .Values.externalDatabase.url -}}
{{- end -}}
{{- if and (not $external) .Values.mongodb -}}
  {{- $external = default "" (index .Values "mongodb" "url") -}}
{{- end -}}
{{- if and .Values.ferretdb.enabled (not $external) -}}
  {{- printf "mongodb://%s:%v/%s?directConnection=true" (include "wekan.ferretdb.fullname" .) .Values.ferretdb.service.port .Values.dbname -}}
{{- else -}}
  {{- if contains "directConnection" $external -}}
    {{- $external -}}
  {{- else if contains "?" $external -}}
    {{- printf "%s&directConnection=true" $external -}}
  {{- else -}}
    {{- printf "%s?directConnection=true" $external -}}
  {{- end -}}
{{- end -}}
{{- end -}}
