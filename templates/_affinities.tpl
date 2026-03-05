{{/*
Pod and node affinity helpers.
Follows the Bitnami preset pattern (soft/hard) with full override support.

Values pattern (per component):
  podAffinityPreset: ""          # "", "soft", or "hard"
  podAntiAffinityPreset: ""      # "", "soft", or "hard"
  nodeAffinityPreset:
    type: ""                     # "", "soft", or "hard"
    key: ""                      # node label key
    values: []                   # node label values
  affinity: {}                   # full override (ignores all presets when set)
*/}}

{{/*
Return the topology key (defaults to kubernetes.io/hostname).
Usage: {{ include "comet-common.affinities.topologyKey" (dict "topologyKey" "BAR") }}
*/}}
{{- define "comet-common.affinities.topologyKey" -}}
{{ .topologyKey | default "kubernetes.io/hostname" -}}
{{- end -}}

{{/*
Return a soft nodeAffinity definition.
Usage: {{ include "comet-common.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) }}
*/}}
{{- define "comet-common.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
    weight: 1
{{- end -}}

{{/*
Return a hard nodeAffinity definition.
Usage: {{ include "comet-common.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) }}
*/}}
{{- define "comet-common.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Return a nodeAffinity definition (dispatches to soft or hard).
Usage: {{ include "comet-common.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) }}
*/}}
{{- define "comet-common.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "comet-common.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "comet-common.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition.
Uses comet-common.selectorLabels for matchLabels, passing componentName for app.kubernetes.io/component.
Usage: {{ include "comet-common.affinities.pods.soft" (dict "component" "FOO" "topologyKey" "BAR" "context" $) }}
*/}}
{{- define "comet-common.affinities.pods.soft" -}}
{{- $component := default "" .component -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "comet-common.selectorLabels" (dict "componentName" $component "customLabels" (dict) "context" .context)) | nindent 10 }}
      topologyKey: {{ include "comet-common.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition.
Uses comet-common.selectorLabels for matchLabels, passing componentName for app.kubernetes.io/component.
Usage: {{ include "comet-common.affinities.pods.hard" (dict "component" "FOO" "topologyKey" "BAR" "context" $) }}
*/}}
{{- define "comet-common.affinities.pods.hard" -}}
{{- $component := default "" .component -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "comet-common.selectorLabels" (dict "componentName" $component "customLabels" (dict) "context" .context)) | nindent 8 }}
    topologyKey: {{ include "comet-common.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition (dispatches to soft or hard).
Returns empty string when type is "" (disabled).
Usage: {{ include "comet-common.affinities.pods" (dict "type" "soft" "component" "FOO" "context" $) }}
*/}}
{{- define "comet-common.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "comet-common.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "comet-common.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}
