{{/*
Helpers imported and adapted from the Bitnami "common" library chart.

Bitnami stopped maintaining the upstream common chart, so the generically-useful
helpers we relied on are ported here (renamed under the comet-common.* namespace).
Helpers that this chart already provides (names, labels, images, tplvalues,
affinities, size presets) are NOT duplicated here.

Source: https://github.com/bitnami/charts/tree/main/bitnami/common/templates
Original copyright: Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* ======================================================================
     Names
     ====================================================================== */}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "comet-common.names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* ======================================================================
     Capabilities
     ====================================================================== */}}

{{/*
Return the target Kubernetes version
*/}}
{{- define "comet-common.capabilities.kubeVersion" -}}
{{- default (default .Capabilities.KubeVersion.Version .Values.kubeVersion) ((.Values.global).kubeVersion) -}}
{{- end -}}

{{/*
Return true if the apiVersion is supported
Usage:
{{ include "comet-common.capabilities.apiVersions.has" (dict "version" "batch/v1" "context" $) }}
*/}}
{{- define "comet-common.capabilities.apiVersions.has" -}}
{{- $providedAPIVersions := default .context.Values.apiVersions ((.context.Values.global).apiVersions) -}}
{{- if and (empty $providedAPIVersions) (.context.Capabilities.APIVersions.Has .version) -}}
    {{- true -}}
{{- else if has .version $providedAPIVersions -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "comet-common.capabilities.policy.apiVersion" -}}
{{- print "policy/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "comet-common.capabilities.networkPolicy.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for job.
*/}}
{{- define "comet-common.capabilities.job.apiVersion" -}}
{{- print "batch/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for cronjob.
*/}}
{{- define "comet-common.capabilities.cronjob.apiVersion" -}}
{{- print "batch/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for daemonset.
*/}}
{{- define "comet-common.capabilities.daemonset.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "comet-common.capabilities.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for statefulset.
*/}}
{{- define "comet-common.capabilities.statefulset.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "comet-common.capabilities.ingress.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for RBAC resources.
*/}}
{{- define "comet-common.capabilities.rbac.apiVersion" -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for CRDs.
*/}}
{{- define "comet-common.capabilities.crd.apiVersion" -}}
{{- print "apiextensions.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for APIService.
*/}}
{{- define "comet-common.capabilities.apiService.apiVersion" -}}
{{- print "apiregistration.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "comet-common.capabilities.hpa.apiVersion" -}}
{{- $kubeVersion := include "comet-common.capabilities.kubeVersion" .context -}}
{{- print "autoscaling/v2" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for Vertical Pod Autoscaler.
*/}}
{{- define "comet-common.capabilities.vpa.apiVersion" -}}
{{- print "autoscaling.k8s.io/v1" -}}
{{- end -}}

{{/*
Returns true if PodSecurityPolicy is supported
*/}}
{{- define "comet-common.capabilities.psp.supported" -}}
{{- $kubeVersion := include "comet-common.capabilities.kubeVersion" . -}}
{{- if or (empty $kubeVersion) (semverCompare "<1.25-0" $kubeVersion) -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if AdmissionConfiguration is supported
*/}}
{{- define "comet-common.capabilities.admissionConfiguration.supported" -}}
{{- $kubeVersion := include "comet-common.capabilities.kubeVersion" . -}}
  {{- true -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for AdmissionConfiguration.
*/}}
{{- define "comet-common.capabilities.admissionConfiguration.apiVersion" -}}
{{- $kubeVersion := include "comet-common.capabilities.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.25-0" $kubeVersion) -}}
{{- print "apiserver.config.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "apiserver.config.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for PodSecurityConfiguration.
*/}}
{{- define "comet-common.capabilities.podSecurityConfiguration.apiVersion" -}}
{{- $kubeVersion := include "comet-common.capabilities.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.25-0" $kubeVersion) -}}
{{- print "pod-security.admission.config.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "pod-security.admission.config.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if the used Helm version is 3.3+.
A way to check the used Helm version was not introduced until version 3.3.0 with .Capabilities.HelmVersion, which contains an additional "{}}"  structure.
This check is introduced as a regexMatch instead of {{ if .Capabilities.HelmVersion }} because checking for the key HelmVersion in <3.3 results in a "interface not found" error.
**To be removed when the catalog's minimun Helm version is 3.3**
*/}}
{{- define "comet-common.capabilities.supportsHelmVersion" -}}
{{- if regexMatch "{(v[0-9])*[^}]*}}$" (.Capabilities | toString ) }}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* ======================================================================
     Storage
     ====================================================================== */}}

{{/*
Return the proper Storage Class
{{ include "comet-common.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "comet-common.storage.class" -}}
{{- $storageClass := (.global).storageClass | default .persistence.storageClass | default (.global).defaultStorageClass | default "" -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else -}}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/* ======================================================================
     Ingress
     ====================================================================== */}}

{{/*
Generate backend entry that is compatible with all Kubernetes API versions.

Usage:
{{ include "comet-common.ingress.backend" (dict "serviceName" "backendName" "servicePort" "backendPort" "context" $) }}

Params:
  - serviceName - String. Name of an existing service backend
  - servicePort - String/Int. Port name (or number) of the service. It will be translated to different yaml depending if it is a string or an integer.
  - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "comet-common.ingress.backend" -}}
service:
  name: {{ .serviceName }}
  port:
    {{- if typeIs "string" .servicePort }}
    name: {{ .servicePort }}
    {{- else if or (typeIs "int" .servicePort) (typeIs "float64" .servicePort) }}
    number: {{ .servicePort | int }}
    {{- end }}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed
certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
Usage:
{{ include "comet-common.ingress.certManagerRequest" ( dict "annotations" .Values.path.to.the.ingress.annotations ) }}
*/}}
{{- define "comet-common.ingress.certManagerRequest" -}}
{{ if or (hasKey .annotations "cert-manager.io/cluster-issuer") (hasKey .annotations "cert-manager.io/issuer") (hasKey .annotations "kubernetes.io/tls-acme") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/* ======================================================================
     Utils
     ====================================================================== */}}

{{/*
Print instructions to get a secret value.
Usage:
{{ include "comet-common.utils.secret.getvalue" (dict "secret" "secret-name" "field" "secret-value-field" "context" $) }}
*/}}
{{- define "comet-common.utils.secret.getvalue" -}}
{{- $varname := include "comet-common.utils.fieldToEnvVar" . -}}
export {{ $varname }}=$(kubectl get secret --namespace {{ include "comet-common.names.namespace" .context | quote }} {{ .secret }} -o jsonpath="{.data.{{ .field }}}" | base64 -d)
{{- end -}}

{{/*
Build env var name given a field
Usage:
{{ include "comet-common.utils.fieldToEnvVar" dict "field" "my-password" }}
*/}}
{{- define "comet-common.utils.fieldToEnvVar" -}}
  {{- $fieldNameSplit := splitList "-" .field -}}
  {{- $upperCaseFieldNameSplit := list -}}

  {{- range $fieldNameSplit -}}
    {{- $upperCaseFieldNameSplit = append $upperCaseFieldNameSplit ( upper . ) -}}
  {{- end -}}

  {{ join "_" $upperCaseFieldNameSplit }}
{{- end -}}

{{/*
Gets a value from .Values given
Usage:
{{ include "comet-common.utils.getValueFromKey" (dict "key" "path.to.key" "context" $) }}
*/}}
{{- define "comet-common.utils.getValueFromKey" -}}
{{- $splitKey := splitList "." .key -}}
{{- $value := "" -}}
{{- $latestObj := $.context.Values -}}
{{- range $splitKey -}}
  {{- if not $latestObj -}}
    {{- printf "please review the entire path of '%s' exists in values" $.key | fail -}}
  {{- end -}}
  {{- $value = ( index $latestObj . ) -}}
  {{- $latestObj = $value -}}
{{- end -}}
{{- printf "%v" (default "" $value) -}}
{{- end -}}

{{/*
Returns first .Values key with a defined value or first of the list if all non-defined
Usage:
{{ include "comet-common.utils.getKeyFromList" (dict "keys" (list "path.to.key1" "path.to.key2") "context" $) }}
*/}}
{{- define "comet-common.utils.getKeyFromList" -}}
{{- $key := first .keys -}}
{{- $reverseKeys := reverse .keys }}
{{- range $reverseKeys }}
  {{- $value := include "comet-common.utils.getValueFromKey" (dict "key" . "context" $.context ) }}
  {{- if $value -}}
    {{- $key = . }}
  {{- end -}}
{{- end -}}
{{- printf "%s" $key -}}
{{- end -}}

{{/*
Checksum a template at "path" containing a *single* resource (ConfigMap,Secret) for use in pod annotations, excluding the metadata (see #18376).
Usage:
{{ include "comet-common.utils.checksumTemplate" (dict "path" "/configmap.yaml" "context" $) }}
*/}}
{{- define "comet-common.utils.checksumTemplate" -}}
{{- $obj := include (print .context.Template.BasePath .path) .context | fromYaml -}}
{{ omit $obj "apiVersion" "kind" "metadata" | toYaml | sha256sum }}
{{- end -}}

{{/* ======================================================================
     Errors

     Trimmed port of Bitnami's common.errors.upgrade.passwords.empty. The
     upstream version pulls in the common.validations.* tree and links to
     bitnami.com docs; here we keep a generic message and the same upgrade
     guard so secrets.passwords.manage can fail safely on empty upgrades.
     ====================================================================== */}}

{{/*
Throw error when upgrading using empty passwords values that must not be empty.

Usage:
{{ include "comet-common.errors.upgrade.passwords.empty" (dict "validationErrors" (list $validationError00 $validationError01) "context" $) }}

Params:
  - validationErrors - List<String> - Required. List of validation strings; if all empty no error is thrown.
  - context - Context - Required. Parent context.
*/}}
{{- define "comet-common.errors.upgrade.passwords.empty" -}}
  {{- $validationErrors := join "" .validationErrors -}}
  {{- if and $validationErrors .context.Release.IsUpgrade -}}
    {{- $errorString := "\nPASSWORDS ERROR: You must provide your current passwords when upgrading the release." -}}
    {{- $errorString = print $errorString "\n                 Note that even after reinstallation, old credentials may be needed as they may be kept in persistent volume claims." -}}
    {{- $errorString = print $errorString "\n%s" -}}
    {{- printf $errorString $validationErrors | fail -}}
  {{- end -}}
{{- end -}}

{{/*
Validate that a required password value is not empty (generic port of
common.validations.values.single.empty, minus the Bitnami subchart wiring).
Returns a non-empty error string when the resolved value is empty.

Usage:
{{ include "comet-common.validations.values.single.empty" (dict "valueKey" "path.to.password" "secret" "secretName" "field" "password-field" "context" $) }}
*/}}
{{- define "comet-common.validations.values.single.empty" -}}
  {{- $value := include "comet-common.utils.getValueFromKey" (dict "key" .valueKey "context" .context) }}
  {{- if not $value -}}
    {{- $varname := "my-value" -}}
    {{- $getCurrentValue := "" -}}
    {{- if and .secret .field -}}
      {{- $varname = include "comet-common.utils.fieldToEnvVar" . -}}
      {{- $getCurrentValue = printf " To get the current value:\n\n        %s\n" (include "comet-common.utils.secret.getvalue" .) -}}
    {{- end -}}
    {{- printf "\n    '%s' must not be empty, please add '--set %s=$%s' to the command.%s" .valueKey .valueKey $varname $getCurrentValue -}}
  {{- end -}}
{{- end -}}

{{/* ======================================================================
     Secrets
     ====================================================================== */}}

{{/*
Generate secret name.

Usage:
{{ include "comet-common.secrets.name" (dict "existingSecret" .Values.path.to.the.existingSecret "defaultNameSuffix" "mySuffix" "context" $) }}

Params:
  - existingSecret - ExistingSecret/String - Optional. The path to the existing secrets in the values.yaml given by the user
    to be used instead of the default one. Allows for it to be of type String (just the secret name) for backwards compatibility.
  - defaultNameSuffix - String - Optional. It is used only if we have several secrets in the same deployment.
  - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "comet-common.secrets.name" -}}
{{- $name := (include "comet-common.names.fullname" .context) -}}

{{- if .defaultNameSuffix -}}
{{- $name = printf "%s-%s" $name .defaultNameSuffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- with .existingSecret -}}
{{- if not (typeIs "string" .) -}}
{{- with .name -}}
{{- $name = . -}}
{{- end -}}
{{- else -}}
{{- $name = . -}}
{{- end -}}
{{- end -}}

{{- printf "%s" $name -}}
{{- end -}}

{{/*
Generate secret key.

Usage:
{{ include "comet-common.secrets.key" (dict "existingSecret" .Values.path.to.the.existingSecret "key" "keyName") }}

Params:
  - existingSecret - ExistingSecret/String - Optional. The path to the existing secrets in the values.yaml given by the user
    to be used instead of the default one. Allows for it to be of type String (just the secret name) for backwards compatibility.
  - key - String - Required. Name of the key in the secret.
*/}}
{{- define "comet-common.secrets.key" -}}
{{- $key := .key -}}

{{- if .existingSecret -}}
  {{- if not (typeIs "string" .existingSecret) -}}
    {{- if .existingSecret.keyMapping -}}
      {{- $key = index .existingSecret.keyMapping $.key -}}
    {{- end -}}
  {{- end }}
{{- end -}}

{{- printf "%s" $key -}}
{{- end -}}

{{/*
Generate secret password or retrieve one if already created.

Usage:
{{ include "comet-common.secrets.passwords.manage" (dict "secret" "secret-name" "key" "keyName" "providedValues" (list "path.to.password1" "path.to.password2") "length" 10 "strong" false "chartName" "chartName" "honorProvidedValues" false "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - key - String - Required - Name of the key in the secret.
  - providedValues - List<String> - Required - The path to the validating value in the values.yaml, e.g: "mysql.password". Will pick first parameter with a defined value.
  - length - int - Optional - Length of the generated random password.
  - strong - Boolean - Optional - Whether to add symbols to the generated random password.
  - chartName - String - Optional - Name of the chart used when said chart is deployed as a subchart.
  - context - Context - Required - Parent context.
  - failOnNew - Boolean - Optional - Default to true. If set to false, skip errors adding new keys to existing secrets.
  - skipB64enc - Boolean - Optional - Default to false. If set to true, the secret will not be base64 encoded.
  - skipQuote - Boolean - Optional - Default to false. If set to true, no quotes will be added around the secret.
  - honorProvidedValues - Boolean - Optional - Default to false. If set to true, the values in providedValues have higher priority than an existing secret

The order in which this function returns a secret password:
  1. Password provided via the values.yaml if honorProvidedValues = true
  2. Already existing 'Secret' resource
  3. Password provided via the values.yaml if honorProvidedValues = false
  4. Randomly generated secret password
*/}}
{{- define "comet-common.secrets.passwords.manage" -}}

{{- $password := "" }}
{{- $subchart := "" }}
{{- $chartName := default "" .chartName }}
{{- $passwordLength := default 10 .length }}
{{- $providedPasswordKey := include "comet-common.utils.getKeyFromList" (dict "keys" .providedValues "context" $.context) }}
{{- $providedPasswordValue := include "comet-common.utils.getValueFromKey" (dict "key" $providedPasswordKey "context" $.context) }}
{{- $secretData := (lookup "v1" "Secret" (include "comet-common.names.namespace" .context) .secret).data }}
{{- if $secretData }}
  {{- if hasKey $secretData .key }}
    {{- $password = index $secretData .key | b64dec }}
  {{- else if not (eq .failOnNew false) }}
    {{- printf "\nPASSWORDS ERROR: The secret \"%s\" does not contain the key \"%s\"\n" .secret .key | fail -}}
  {{- end -}}
{{- end }}

{{- if and $providedPasswordValue .honorProvidedValues }}
  {{- $password = tpl ($providedPasswordValue | toString) .context }}
{{- end }}

{{- if not $password }}
  {{- if $providedPasswordValue }}
    {{- $password = tpl ($providedPasswordValue | toString) .context }}
  {{- else }}
    {{- if .context.Values.enabled }}
      {{- $subchart = $chartName }}
    {{- end -}}

    {{- if not (eq .failOnNew false) }}
      {{- $requiredPassword := dict "valueKey" $providedPasswordKey "secret" .secret "field" .key "subchart" $subchart "context" $.context -}}
      {{- $requiredPasswordError := include "comet-common.validations.values.single.empty" $requiredPassword -}}
      {{- $passwordValidationErrors := list $requiredPasswordError -}}
      {{- include "comet-common.errors.upgrade.passwords.empty" (dict "validationErrors" $passwordValidationErrors "context" $.context) -}}
    {{- end }}

    {{- if .strong }}
      {{- $subStr := list (lower (randAlpha 1)) (randNumeric 1) (upper (randAlpha 1)) | join "_" }}
      {{- $password = randAscii $passwordLength }}
      {{- $password = regexReplaceAllLiteral "\\W" $password "@" | substr 5 $passwordLength }}
      {{- $password = printf "%s%s" $subStr $password | toString | shuffle }}
    {{- else }}
      {{- $password = randAlphaNum $passwordLength }}
    {{- end }}
  {{- end -}}
{{- end -}}
{{- if not .skipB64enc }}
{{- $password = $password | b64enc }}
{{- end -}}
{{- if .skipQuote -}}
{{- printf "%s" $password -}}
{{- else -}}
{{- printf "%s" $password | quote -}}
{{- end -}}
{{- end -}}

{{/*
Reuses the value from an existing secret, otherwise sets its value to a default value.

Usage:
{{ include "comet-common.secrets.lookup" (dict "secret" "secret-name" "key" "keyName" "defaultValue" .Values.myValue "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - key - String - Required - Name of the key in the secret.
  - defaultValue - String - Required - The path to the validating value in the values.yaml, e.g: "mysql.password". Will pick first parameter with a defined value.
  - context - Context - Required - Parent context.
*/}}
{{- define "comet-common.secrets.lookup" -}}
{{- $value := "" -}}
{{- $secretData := (lookup "v1" "Secret" (include "comet-common.names.namespace" .context) .secret).data -}}
{{- if and $secretData (hasKey $secretData .key) -}}
  {{- $value = index $secretData .key -}}
{{- else if .defaultValue -}}
  {{- $value = .defaultValue | toString | b64enc -}}
{{- end -}}
{{- if $value -}}
{{- printf "%s" $value -}}
{{- end -}}
{{- end -}}

{{/*
Returns whether a previous generated secret already exists

Usage:
{{ include "comet-common.secrets.exists" (dict "secret" "secret-name" "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - context - Context - Required - Parent context.
*/}}
{{- define "comet-common.secrets.exists" -}}
{{- $secret := (lookup "v1" "Secret" (include "comet-common.names.namespace" .context) .secret) }}
{{- if $secret }}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* ======================================================================
     Compatibility
     ====================================================================== */}}

{{/*
Return true if the detected platform is Openshift
Usage:
{{- include "comet-common.compatibility.isOpenshift" . -}}
*/}}
{{- define "comet-common.compatibility.isOpenshift" -}}
{{- if .Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Render a compatible securityContext depending on the platform. By default it is maintained as it is. In other platforms like Openshift we remove default user/group values that do not work out of the box with the restricted-v1 SCC
Usage:
{{- include "comet-common.compatibility.renderSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) -}}
*/}}
{{- define "comet-common.compatibility.renderSecurityContext" -}}
{{- $adaptedContext := .secContext -}}

{{- if (((.context.Values.global).compatibility).openshift) -}}
  {{- if or (eq .context.Values.global.compatibility.openshift.adaptSecurityContext "force") (and (eq .context.Values.global.compatibility.openshift.adaptSecurityContext "auto") (include "comet-common.compatibility.isOpenshift" .context)) -}}
    {{/* Remove incompatible user/group values that do not work in Openshift out of the box */}}
    {{- $adaptedContext = omit $adaptedContext "fsGroup" "runAsUser" "runAsGroup" -}}
    {{- if not .secContext.seLinuxOptions -}}
    {{/* If it is an empty object, we remove it from the resulting context because it causes validation issues */}}
    {{- $adaptedContext = omit $adaptedContext "seLinuxOptions" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{/* Remove empty seLinuxOptions object if global.compatibility.omitEmptySeLinuxOptions is set to true */}}
{{- if and (((.context.Values.global).compatibility).omitEmptySeLinuxOptions) (not .secContext.seLinuxOptions) -}}
  {{- $adaptedContext = omit $adaptedContext "seLinuxOptions" -}}
{{- end -}}
{{/* Remove fields that are disregarded when running the container in privileged mode */}}
{{- if $adaptedContext.privileged -}}
  {{- $adaptedContext = omit $adaptedContext "capabilities" -}}
{{- end -}}
{{- omit $adaptedContext "enabled" | toYaml -}}
{{- end -}}
