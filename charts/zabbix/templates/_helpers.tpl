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
helm.sh/chart: {{ include "zabbix.chart" . }}
{{ include "zabbix.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zabbix.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zabbix.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "zabbix.serviceAccountName" -}}
{{- if or .Values.serviceAccount.create (and .Values.zabbixServer.enabled .Values.zabbixServer.zabbixServerHA.enabled ) -}}
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
Return the entire logic of setting PostgreSQL access related env vars for the containers which need them
*/}}
{{- define "zabbix.postgresAccess.variables" -}}
{{- $ := index . 0 }}
{{- $cntxt := index . 2 }}
{{- with index . 1 }}
{{- $hostvar := "DB_SERVER_HOST" }}
{{- $portvar := "DB_SERVER_PORT" }}
{{- $uservar := "POSTGRES_USER" }}
{{- $passwordvar := "POSTGRES_PASSWORD" }}
{{- $dbvar := "POSTGRES_DB" }}
{{- $schemavar := "DB_SERVER_SCHEMA" }}
{{/* special settings for the DB client (autoclean cron job) container, needs different env variable names */}}
{{- if eq $cntxt "db_client" }}
{{- $hostvar = "PGHOST" }}
{{- $portvar = "PGPORT" }}
{{- $uservar = "PGUSER" }}
{{- $passwordvar = "PGPASSWORD" }}
{{- $dbvar = "PGDATABASE" }}
{{- end }}
{{- $fullname := include "zabbix.fullname" . }}
{{- $secretName := printf "%s-%s" $fullname "db-access" }}
{{- if .Values.postgresAccess.existingSecretName }}
{{- $secretName = .Values.postgresAccess.existingSecretName }}
{{- end }}

{{- if .Values.postgresql.enabled }}
- name: {{ $hostvar }}
  value: {{ template "zabbix.fullname" . }}-postgresql
- name: {{ $portvar }}
  value: {{ .Values.postgresql.service.port | quote }}
{{- else if and (eq $cntxt "db_init_upgrade") (not .Values.postgresAccess.existingSecretName) }}
- name: {{ $hostvar }}
  value: {{ .Values.postgresAccess.host | quote }}
- name: {{ $portvar }}
  value: {{ .Values.postgresAccess.port | quote }}
{{- else }}
{{- if and .Values.postgresAccess.existingSecretName .Values.postgresAccess.secretHostKey }}
- name: {{ $hostvar }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ .Values.postgresAccess.secretHostKey }}
{{- else }}
- name: {{ $hostvar }}
  value: {{ .Values.postgresAccess.host | quote }}
{{- end }}
{{- if and .Values.postgresAccess.existingSecretName .Values.postgresAccess.secretPortKey }}
- name: {{ $portvar }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ .Values.postgresAccess.secretPortKey }}
      optional: true
{{- else }}
- name: {{ $portvar }}
  value: {{ .Values.postgresAccess.port | quote }}
{{- end }}
{{- end }}

{{- if and (eq $cntxt "db_init_upgrade") (not .Values.postgresAccess.existingSecretName) }}
- name: {{ $uservar }}
  value: {{ .Values.postgresAccess.user | quote }}
- name: {{ $passwordvar }}
  value: {{ .Values.postgresAccess.password | quote }}
- name: {{ $dbvar }}
  value: {{ .Values.postgresAccess.database | quote }}
  {{- if and (not .Values.postgresql.enabled) .Values.postgresAccess.schema }}
- name: {{ $schemavar }}
  value: {{ .Values.postgresAccess.schema }}
  {{- end }}
{{- else }}
- name: {{ $uservar }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ .Values.postgresAccess.secretUserKey }}
      optional: true
- name: {{ $passwordvar }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ .Values.postgresAccess.secretPasswordKey }}
{{- if and .Values.postgresAccess.existingSecretName .Values.postgresAccess.secretDBKey }}
- name: {{ $dbvar }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ .Values.postgresAccess.secretDBKey }}
      optional: true
{{- else }}
- name: {{ $dbvar }}
  value: {{ .Values.postgresAccess.database | quote }}
{{- end }}
  {{- if and (not .Values.postgresql.enabled) .Values.postgresAccess.secretSchemaKey }}
- name: {{ $schemavar }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ .Values.postgresAccess.secretSchemaKey }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Render a piece of yaml that defines manifests
Usage:
{{ include "zabbix.tools.render" ( dict "value" .Values.path.to.value "context" $ ) }}
*/}}
{{- define "zabbix.tools.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" $value }}
  {{- tpl $value .context }}
{{- else }}
  {{- $value }}
{{- end }}
{{- end -}}
