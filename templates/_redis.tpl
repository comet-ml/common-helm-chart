{{/*
Redis configuration helpers.
All helpers read from .Values.global.redis.* which are propagated by Helm's
global value mechanism from the umbrella chart.

Usage:
  {{ include "comet-common.redis.value" (dict "root" . "key" "redisHost" "default" "comet-ml-redis-master") }}
  {{ include "comet-common.redis.url" . }}
  {{ include "comet-common.redis.url" (dict "root" . "db" "2" "sslParams" true) }}
*/}}

{{/*
Get Redis configuration value from .Values.global.redis.*
Usage: {{ include "comet-common.redis.value" (dict "root" . "key" "redisHost" "default" "comet-ml-redis-master") }}
*/}}
{{- define "comet-common.redis.value" -}}
  {{- $root := .root -}}
  {{- $key := .key -}}
  {{- $default := .default | default "" -}}
  {{- if hasKey $root.Values.global.redis $key -}}
    {{- index $root.Values.global.redis $key -}}
  {{- else -}}
    {{- $default -}}
  {{- end -}}
{{- end -}}

{{/*
Generate Redis URL with flexible parameters.
Supports both simple invocation (passing context directly) and dict-based parameters.
Usage:
  {{ include "comet-common.redis.url" . }}                                      # db=0, no SSL params
  {{ include "comet-common.redis.url" (dict "root" . "db" "2") }}               # db=2
  {{ include "comet-common.redis.url" (dict "root" . "db" "5" "sslParams" true) }}  # db=5 with SSL params
*/}}
{{- define "comet-common.redis.url" }}
  {{- $root := . -}}
  {{- $db := "0" -}}
  {{- $sslParams := false -}}
  {{- if kindIs "map" . -}}
    {{- $root = .root -}}
    {{- $db = .db | default "0" -}}
    {{- $sslParams = .sslParams | default false -}}
  {{- end -}}
  {{- $redisHost := include "comet-common.redis.value" (dict "root" $root "key" "redisHost" "default" "comet-ml-redis-master") -}}
  {{- $redisPort := include "comet-common.redis.value" (dict "root" $root "key" "redisPort" "default" "6379") -}}
  {{- $redisToken := include "comet-common.redis.value" (dict "root" $root "key" "redisToken" "default" "NA") -}}
  {{- $redisUser := include "comet-common.redis.value" (dict "root" $root "key" "redisUser") -}}
  {{- $redisSSL := include "comet-common.redis.value" (dict "root" $root "key" "redisSSL" "default" "false") -}}
  {{- $protocol := ternary "rediss" "redis" (eq $redisSSL "true") -}}
  {{- if or (eq $redisToken "NA") (eq $redisToken "") -}}
    {{- if $redisUser -}}
      {{- printf "%s://%s@%s:%s/%s" $protocol $redisUser $redisHost $redisPort $db -}}
    {{- else -}}
      {{- printf "%s://%s:%s/%s" $protocol $redisHost $redisPort $db -}}
    {{- end -}}
  {{- else -}}
    {{- $url := "" -}}
    {{- if $redisUser -}}
      {{- $url = printf "%s://%s:%s@%s:%s/%s" $protocol $redisUser $redisToken $redisHost $redisPort $db -}}
    {{- else -}}
      {{- $url = printf "%s://:%s@%s:%s/%s" $protocol $redisToken $redisHost $redisPort $db -}}
    {{- end -}}
    {{- if and (eq $redisSSL "true") $sslParams -}}
      {{- printf "%s?ssl_cert_reqs=none" $url -}}
    {{- else -}}
      {{- $url -}}
    {{- end -}}
  {{- end -}}
{{- end }}
