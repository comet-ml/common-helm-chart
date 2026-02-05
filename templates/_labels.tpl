{{/*
Component label

  {{ include "comet-common.labels.component" . -}}
  {{ include "comet-common.labels.component" (dict "componentName" .Values.componentName "context" $) -}}
*/}}
{{- define "comet-common.labels.component" -}}
  {{- if not (empty .componentName) -}}
app.kubernetes.io/component: {{ .componentName }}
  {{- else -}}
app.kubernetes.io/component: {{ include "comet-common.names.name" (ternary .context $ (hasKey . "context")) }}
  {{- end -}}
{{- end }}

{{/*
Kubernetes base labels

  {{ include "comet-common.labels.base" (dict "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "comet-common.labels.base" -}}
  {{- if and (hasKey . "customLabels") (hasKey . "context") -}}
    {{- $default := dict "app.kubernetes.io/name" (include "comet-common.names.name" .context) "helm.sh/chart" (include "comet-common.names.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
    {{- with .context.Chart.AppVersion -}}
      {{- $_ := set $default "app.kubernetes.io/version" . -}}
    {{- end -}}
{{ template "comet-common.tplvalues.merge" (dict "values" (list .customLabels $default) "context" .context) }}
  {{- else -}}
app.kubernetes.io/name: {{ include "comet-common.names.name" . }}
helm.sh/chart: {{ include "comet-common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
    {{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | replace "+" "_" | quote }}
    {{- end -}}
  {{- end -}}
{{- end }}

{{/*
Common labels

  {{ include "comet-common.labels" . -}}
or
  {{ include "comet-common.labels" (dict "componentName" .Values.componentName "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "comet-common.labels" -}}
{{ include "comet-common.labels.base" . }}
{{ include "comet-common.labels.component" . }}
{{- end }}

{{/*
Selector labels

  {{ include "comet-common.selectorLabels" . -}}
or
  {{ include "comet-common.selectorLabels" (dict "componentName" .Values.componentName "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "comet-common.selectorLabels" -}}
  {{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{ merge (pick (include "comet-common.tplvalues.render" (dict "value" .customLabels "context" .context) | fromYaml) "app.kubernetes.io/name" "app.kubernetes.io/instance") (dict "app.kubernetes.io/name" (include "comet-common.names.name" .context) "app.kubernetes.io/instance" .context.Release.Name ) | toYaml }}
  {{- else -}}
app.kubernetes.io/name: {{ include "comet-common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
  {{- end }}
{{ include "comet-common.labels.component" . }}
{{- end }}
