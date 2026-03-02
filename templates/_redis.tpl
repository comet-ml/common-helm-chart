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
Build a Redis URL from an explicit config dict.
This is the shared implementation used by both comet-common.redis.url and chart-specific Redis helpers.
Usage: {{ include "comet-common.redis.buildUrl" (dict "host" "localhost" "port" "6379" "token" "NA" "user" "" "ssl" "false" "db" "0" "sslParams" false) }}
*/}}
{{- define "comet-common.redis.buildUrl" -}}
  {{- $host := .host -}}
  {{- $port := .port | toString -}}
  {{- $token := .token | default "NA" | toString -}}
  {{- $user := .user | default "" | toString -}}
  {{- $ssl := .ssl | default "false" | toString -}}
  {{- $db := .db | default "0" | toString -}}
  {{- $sslParams := .sslParams | default false -}}
  {{- $protocol := ternary "rediss" "redis" (eq $ssl "true") -}}
  {{- if or (eq $token "NA") (eq $token "") -}}
    {{- if $user -}}
      {{- printf "%s://%s@%s:%s/%s" $protocol $user $host $port $db -}}
    {{- else -}}
      {{- printf "%s://%s:%s/%s" $protocol $host $port $db -}}
    {{- end -}}
  {{- else -}}
    {{- $url := "" -}}
    {{- if $user -}}
      {{- $url = printf "%s://%s:%s@%s:%s/%s" $protocol $user $token $host $port $db -}}
    {{- else -}}
      {{- $url = printf "%s://:%s@%s:%s/%s" $protocol $token $host $port $db -}}
    {{- end -}}
    {{- if and (eq $ssl "true") $sslParams -}}
      {{- printf "%s?ssl_cert_reqs=none" $url -}}
    {{- else -}}
      {{- $url -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate Redis URL from global.redis.* values.
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
  {{- include "comet-common.redis.buildUrl" (dict
    "host" (include "comet-common.redis.value" (dict "root" $root "key" "redisHost" "default" "comet-redis-master"))
    "port" (include "comet-common.redis.value" (dict "root" $root "key" "redisPort" "default" "6379"))
    "token" (include "comet-common.redis.value" (dict "root" $root "key" "redisToken" "default" "NA"))
    "user" (include "comet-common.redis.value" (dict "root" $root "key" "redisUser"))
    "ssl" (include "comet-common.redis.value" (dict "root" $root "key" "redisSSL" "default" "false"))
    "db" $db
    "sslParams" $sslParams
  ) -}}
{{- end }}
