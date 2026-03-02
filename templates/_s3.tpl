{{/*
S3 / Object storage configuration helpers.
All helpers read from .Values.global.s3.* which are propagated by Helm's
global value mechanism from the umbrella chart.

Usage:
  {{ include "comet-common.s3.value" (dict "root" . "key" "bucket" "default" "comet-ml-data") }}
  {{ include "comet-common.s3.url" . }}
*/}}

{{/*
Get S3 configuration value from .Values.global.s3.*
Usage: {{ include "comet-common.s3.value" (dict "root" . "key" "keyID" "default" "") }}
*/}}
{{- define "comet-common.s3.value" -}}
  {{- $root := .root -}}
  {{- $key := .key -}}
  {{- $default := .default | default "" -}}
  {{- if hasKey $root.Values.global.s3 $key -}}
    {{- index $root.Values.global.s3 $key -}}
  {{- else -}}
    {{- $default -}}
  {{- end -}}
{{- end -}}

{{/*
Normalize S3 URL with region.
Replaces generic "s3.amazonaws.com" with region-specific "s3.{region}.amazonaws.com".
Passes through non-AWS URLs (e.g. MinIO) unchanged.
Usage: {{ include "comet-common.s3.url" . }}
*/}}
{{- define "comet-common.s3.url" }}
  {{- $s3URL := include "comet-common.s3.value" (dict "root" . "key" "url" "default" "https://s3.amazonaws.com") -}}
  {{- $s3Region := include "comet-common.s3.value" (dict "root" . "key" "region" "default" "us-east-1") -}}
  {{- mustRegexReplaceAll "^(http[s]?://)(s3)(\\.amazonaws\\.com)$" $s3URL (printf "https://${2}.%s${3}" $s3Region) }}
{{- end }}
