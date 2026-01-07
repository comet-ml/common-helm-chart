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
