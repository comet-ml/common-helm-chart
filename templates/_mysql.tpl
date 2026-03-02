{{/*
MySQL configuration helpers.
All helpers read from .Values.global.mysql.* which are propagated by Helm's
global value mechanism from the umbrella chart.

Usage:
  {{ include "comet-common.mysql.host" . }}
  {{ include "comet-common.mysql.url" . }}
  {{ include "comet-common.mysql.readOnlyUrl" . }}
*/}}

{{/* ---- Basic Connection Settings ---- */}}

{{- define "comet-common.mysql.host" -}}
  {{- .Values.global.mysql.mysqlHost | default "comet-ml-mysql" -}}
{{- end -}}

{{- define "comet-common.mysql.port" -}}
  {{- .Values.global.mysql.mysqlPort | default 3306 -}}
{{- end -}}

{{- define "comet-common.mysql.database" -}}
  {{- .Values.global.mysql.mysqlDatabase | default "comet" -}}
{{- end -}}

{{- define "comet-common.mysql.username" -}}
  {{- .Values.global.mysql.mysqlUser | default "" -}}
{{- end -}}

{{- define "comet-common.mysql.password" -}}
  {{- .Values.global.mysql.mysqlPassword | default "" -}}
{{- end -}}

{{/* ---- Admin Credentials (fallback to regular creds) ---- */}}

{{- define "comet-common.mysql.adminUsername" -}}
  {{- default (include "comet-common.mysql.username" .) .Values.global.mysql.mysqlAdminUser -}}
{{- end -}}

{{- define "comet-common.mysql.adminPassword" -}}
  {{- default (include "comet-common.mysql.password" .) .Values.global.mysql.mysqlAdminPassword -}}
{{- end -}}

{{/* ---- SSL / Security ---- */}}

{{- define "comet-common.mysql.useSSL" -}}
  {{- .Values.global.mysql.mysqlUseSSL | default false -}}
{{- end -}}

{{- define "comet-common.mysql.requireSSL" -}}
  {{- .Values.global.mysql.requireSSL | default false -}}
{{- end -}}

{{- define "comet-common.mysql.verifyServerCert" -}}
  {{- .Values.global.mysql.verifyServerCert | default false -}}
{{- end -}}

{{- define "comet-common.mysql.allowPublicKeyRetrieval" -}}
  {{- .Values.global.mysql.allowPublicKeyRetrieval | default false -}}
{{- end -}}

{{/* ---- AWS / IAM ---- */}}

{{- define "comet-common.mysql.awsRegion" -}}
  {{- .Values.global.mysql.awsRegion | default "us-east-1" -}}
{{- end -}}

{{- define "comet-common.mysql.iamEnabled" -}}
  {{- .Values.global.mysql.mysqlIamEnabled | default false -}}
{{- end -}}

{{- define "comet-common.mysql.iamServiceAccountEnabled" -}}
  {{- .Values.global.mysql.mysqlIamServiceAccountEnabled | default false -}}
{{- end -}}

{{/* ---- Connection Pool ---- */}}

{{- define "comet-common.mysql.maxPoolSize" -}}
  {{- .Values.global.mysql.maxPoolSize | default 50 -}}
{{- end -}}

{{/* ---- Replicated MySQL (read-write / read-only) ---- */}}

{{- define "comet-common.mysql.rw.host" -}}
  {{- default (include "comet-common.mysql.host" .) .Values.global.mysql.replicated.rw.host -}}
{{- end -}}

{{- define "comet-common.mysql.rw.username" -}}
  {{- default (include "comet-common.mysql.username" .) .Values.global.mysql.replicated.rw.user -}}
{{- end -}}

{{- define "comet-common.mysql.rw.password" -}}
  {{- default (include "comet-common.mysql.password" .) .Values.global.mysql.replicated.rw.password -}}
{{- end -}}

{{- define "comet-common.mysql.ro.host" -}}
  {{- default (include "comet-common.mysql.host" .) .Values.global.mysql.replicated.ro.host -}}
{{- end -}}

{{- define "comet-common.mysql.ro.username" -}}
  {{- default (include "comet-common.mysql.username" .) .Values.global.mysql.replicated.ro.user -}}
{{- end -}}

{{- define "comet-common.mysql.ro.password" -}}
  {{- default (include "comet-common.mysql.password" .) .Values.global.mysql.replicated.ro.password -}}
{{- end -}}

{{/* ---- Connection URL Builders ---- */}}

{{/*
MySQL connection URL builder (replicated-aware).
When replicated.enabled is true, uses read-write credentials; otherwise uses primary.
Usage: {{ include "comet-common.mysql.url" . }}
*/}}
{{- define "comet-common.mysql.url" }}
  {{- $port := include "comet-common.mysql.port" . -}}
  {{- $database := include "comet-common.mysql.database" . -}}
  {{- if .Values.global.mysql.replicated.enabled -}}
    {{- $host := include "comet-common.mysql.rw.host" . -}}
    {{- $user := include "comet-common.mysql.rw.username" . -}}
    {{- $password := include "comet-common.mysql.rw.password" . -}}
    {{- printf "mysql://%s:%s@%s:%s/%s" $user $password $host $port $database -}}
  {{- else -}}
    {{- $host := include "comet-common.mysql.host" . -}}
    {{- $user := include "comet-common.mysql.username" . -}}
    {{- $password := include "comet-common.mysql.password" . -}}
    {{- printf "mysql://%s:%s@%s:%s/%s" $user $password $host $port $database -}}
  {{- end -}}
{{- end }}

{{/*
MySQL read-only connection URL builder.
Returns read-only URL when replicated.enabled, otherwise falls back to primary URL.
Usage: {{ include "comet-common.mysql.readOnlyUrl" . }}
*/}}
{{- define "comet-common.mysql.readOnlyUrl" }}
  {{- if .Values.global.mysql.replicated.enabled -}}
    {{- $port := include "comet-common.mysql.port" . -}}
    {{- $database := include "comet-common.mysql.database" . -}}
    {{- $host := include "comet-common.mysql.ro.host" . -}}
    {{- $user := include "comet-common.mysql.ro.username" . -}}
    {{- $password := include "comet-common.mysql.ro.password" . -}}
    {{- printf "mysql://%s:%s@%s:%s/%s" $user $password $host $port $database -}}
  {{- else -}}
    {{- include "comet-common.mysql.url" . -}}
  {{- end -}}
{{- end }}
