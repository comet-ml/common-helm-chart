{{/*
Expand the name of the chart.
*/}}
{{- define "comet-common.name" -}}
  {{- default .Chart.Name (default .Values.nameOverride .Values.componentName) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "comet-common.fullname" -}}
  {{- if .Values.fullnameOverride }}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := (include "comet-common.name" .) }}
    {{- if contains $name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "comet-common.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Component label

{{ include "comet-common.labels.component" . -}}
{{ include "comet-common.labels.component" (dict "componentName" .Values.componentName "context" $) -}}
*/}}
{{- define "comet-common.labels.component" -}}
  {{- if not (empty .componentName) -}}
app.kubernetes.io/component: {{ .componentName }}
  {{- else -}}
app.kubernetes.io/component: {{ include "comet-common.name" (ternary .context $ (hasKey . "context")) }}
  {{- end -}}
{{- end }}

{{/*
Common labels

{{ include "comet-common.labels" . -}}
or
{{ include "comet-common.labels" (dict "componentName" .Values.componentName "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "comet-common.labels" -}}
{{ include "common.labels.standard" . }}
{{ include "comet-common.labels.component" . }}
{{- end }}

{{/*
Selector labels

{{ include "comet-common.selectorLabels" . -}}
or
{{ include "comet-common.selectorLabels" (dict "componentName" .Values.componentName "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "comet-common.selectorLabels" -}}
{{ include "common.labels.matchLabels" . }}
{{ include "comet-common.labels.component" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "comet-common.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
{{- default (include "comet-common.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
{{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}

{{/*
Size Preset Lookup
*/}}
{{- define "comet-common.selectSizePreset" -}}
  {{- $component := index . 0 -}}
  {{- $presetPath := index . 1 -}}
  {{- $context := index . 2 -}}
  {{- $pathParts := splitList "." $presetPath -}}
  {{- $result := default (dict) (get (get $context.Values.global.sizePresets $context.Values.global.deploymentSizePreset) $component) -}}
  {{- range $pathParts -}}
    {{- $result = dig . (dict) $result -}}
    {{- if and (kindIs "map" $result) (empty $result) -}}
      {{- $result = nil -}}
    {{- end -}}
  {{- end -}}
  {{- if eq $result nil -}}
    {{- fail (printf "Could not resolve Comet Size Preset: .Values.global.sizePresets.%s.%s" $component $presetPath) -}}
  {{- else -}}
    {{- $result -}}
  {{- end -}}
{{- end }}

{{/*
Resource Block using Size Presets
*/}}
{{- define "comet-common.sizePresets.resources" -}}
  {{- $component := index . 0 -}}
  {{- $resources := index . 1 -}}
  {{- $context := index . 2 -}}
requests:
  memory: {{ default (include "comet-common.selectSizePreset" (list $component "resources.requests.memory" $context)) (dig "requests" "memory" nil $resources) | quote }}
  cpu: {{ default (include "comet-common.selectSizePreset" (list $component "resources.requests.cpu" $context)) (dig "requests" "cpu" nil $resources) | quote }}
limits:
  memory: {{ default (include "comet-common.selectSizePreset" (list $component "resources.limits.memory" $context)) (dig "limits" "memory" nil $resources) | quote }}
  cpu: {{ default (include "comet-common.selectSizePreset" (list $component "resources.limits.cpu" $context)) (dig "limits" "cpu" nil $resources) | quote }}
{{- end }}

{{/*
Render single values or values within collections like dict or list.
If dict or list contains nested collections/structures, it will recurse into
them.

{{ include "comet-common.tplvalues.saferender" (dict "value" .Values.image "context" $) }}
*/}}
{{- define "comet-common.tplvalues.saferender" -}}
  {{- $value := .value -}}
  {{- $context := .context -}}
  {{- if kindIs "map" $value }}
    {{- range $k, $v := $value -}}
      {{- $tmplName := "common.tplvalues.render" -}}
      {{- if or (kindIs "map" $v) (kindIs "list" $v) -}}
        {{- $tmplName = "comet-common.tplvalues.saferender" -}}
      {{- else if not (kindIs "string" $v) -}}
        {{- continue -}}
      {{- end -}}
      {{- $_ := set $value $k (include $tmplName (dict "value" $v "context" $context)) -}}
    {{- end }}
  {{- else if kindIs "list" $value -}}
    {{- $newList := deepCopy $value -}}
    {{- range $i, $v := $value -}}
      {{- $tmplName := "common.tplvalues.render" -}}
      {{- if or (kindIs "map" $v) (kindIs "list" $v) -}}
        {{- $tmplName = "comet-common.tplvalues.saferender" -}}
      {{- else if not (kindIs "string" $v) -}}
        {{- continue -}}
      {{- end -}}
      {{- $newV := include $tmplName (dict "value" $v "context" $context) -}}
      {{- if ne $newV $v -}}
        {{- if eq $i 0 -}}
          {{- $newList = concat (list $newV) (mustSlice (add $i 1)) -}}
        {{- else if eq $i (sub (len $value) 1) -}}
          {{- $newList = concat (mustSlice 0 $i) (list $newV) -}}
        {{- else -}}
          {{- $newList = concat (mustSlice 0 $i) (list $newV) (mustSlice (add $i 1)) -}}
        {{- end -}}
      {{- end -}}
    {{- end }}
    {{- $value = $newList -}}
  {{- else if kindIs "string" $value -}}
    {{- $value = include "common.tplvalues.render" (dict "value" $value "context" $context) -}}
  {{- end }}
  {{- $value | toYaml -}}
{{- end }}
