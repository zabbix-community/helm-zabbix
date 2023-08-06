{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "zabbix.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zabbix.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "zabbix.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "zabbix.labels" -}}
app.kubernetes.io/name: {{ include "zabbix.name" . }}
helm.sh/chart: {{ include "zabbix.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "zabbix.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "zabbix.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "zabbix.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "zabbix.ingress.isStable" -}}
  {{- eq (include "zabbix.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "zabbix.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "zabbix.ingress.isStable" .) "true") (and (eq (include "zabbix.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "zabbix.ingress.supportsPathType" -}}
  {{- or (eq (include "zabbix.ingress.isStable" .) "true") (and (eq (include "zabbix.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}

{{/*
Define env var names

*/}}


{{/*
Return the entire logic of setting PostgreSQL access related env vars for the containers which need them
*/}}
{{- define "zabbix.postgresAccess.variables" -}}
{{- $ := index . 0 }}
{{- $cntxt := index . 2 }}
{{- $hostvar := "DB_SERVER_HOST" }}
{{- $portvar := "DB_SERVER_PORT" }}
{{- $uservar := "POSTGRES_USER" }}
{{- $passwordvar := "POSTGRES_PASSWORD" }}
{{- $dbvar := "POSTGRES_DB" }}
{{/* special settings for the DB client (autoclean cron job) container, needs different env variable names */}}
{{- if eq $cntxt "db_client" }}
{{- $hostvar = "PGHOST" }}
{{- $portvar = "PGPORT" }}
{{- $uservar = "PGUSER" }}
{{- $passwordvar = "PGPASSWORD" }}
{{- $dbvar = "PGDATABASE" }}
{{- end }}
{{- with index . 1 }}
{{- if .Values.postgresql.enabled }}
- name: {{ $hostvar }}
  value: {{ template "zabbix.fullname" . }}-postgresql
- name: {{ $portvar }}
  value: {{ .Values.postgresql.service.port | quote }}
{{- else if .Values.postgresAccess.useUnifiedSecret }}
- name: {{ $hostvar }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresAccess.unifiedSecretName }}
      key: host
- name: {{ $portvar }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresAccess.unifiedSecretName }}
      key: port
      optional: true
{{- else }}
- name: {{ $hostvar }}
  value: {{ .Values.postgresAccess.host | quote }}
- name: {{ $portvar }}
  value: {{ .Values.postgresAccess.port | quote }}
{{- end }}
{{- if .Values.postgresAccess.useUnifiedSecret }}
- name: {{ $uservar }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresAccess.unifiedSecretName }}
      key: user
      optional: true
- name: {{ $passwordvar }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresAccess.unifiedSecretName }}
      key: password
- name: {{ $dbvar }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresAccess.unifiedSecretName }}
      key: dbname
      optional: true
{{- else }}
- name: {{ $uservar }}
  value: {{ .Values.postgresAccess.user | quote }}
- name: {{ $passwordvar }}
  {{- if .Values.postgresAccess.passwordSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresAccess.passwordSecret }}
      key: {{ default "password" .Values.postgresAccess.passwordSecretKey }}
  {{- else  }}
  value: {{ .Values.postgresAccess.password | quote }}
  {{- end }}
- name: {{ $dbvar }}
  value: {{ .Values.postgresAccess.database | quote }}
{{- end }}
{{- end }}
{{- end -}}
