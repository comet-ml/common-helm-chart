{{/*
Renders a value that contains template perhaps with scope if the scope is present.

Usage:
  {{ include "comet-common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ ) }}
  {{ include "comet-common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ "scope" $app ) }}
*/}}
{{- define "comet-common.tplvalues.render" -}}
  {{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
  {{- if contains "{{" (toJson .value) }}
    {{- if .scope }}
        {{- tpl (cat "{{- with $.RelativeScope -}}" $value "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
    {{- else }}
      {{- tpl $value .context }}
    {{- end }}
  {{- else }}
    {{- $value }}
  {{- end }}
{{- end -}}

{{/*
Merge a list of values that contains template after rendering them.
Merge precedence is consistent with http://masterminds.github.io/sprig/dicts.html#merge-mustmerge

Usage:
  {{ include "comet-common.tplvalues.merge" ( dict "values" (list .Values.path.to.the.Value1 .Values.path.to.the.Value2) "context" $ ) }}
*/}}
{{- define "comet-common.tplvalues.merge" -}}
  {{- $dst := dict -}}
  {{- range .values -}}
    {{- $dst = include "comet-common.tplvalues.render" (dict "value" . "context" $.context "scope" $.scope) | fromYaml | merge $dst -}}
  {{- end -}}
{{ $dst | toYaml }}
{{- end -}}

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
      {{- $tmplName := "comet-common.tplvalues.render" -}}
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
      {{- $tmplName := "comet-common.tplvalues.render" -}}
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
    {{- $value = include "comet-common.tplvalues.render" (dict "value" $value "context" $context) -}}
  {{- end }}
  {{- $value | toYaml -}}
{{- end }}
