# Comet Common Library Chart

A Helm library chart providing common helpers for Comet chart deployments.

## Installation

Add this chart as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: comet-common
    version: "x.x.x"
    repository: "oci://ghcr.io/comet-ml"
```

Then run:

```bash
helm dependency update
```

## Available Helpers

### Names

Helpers for generating Kubernetes resource names.

| Helper | Description |
|--------|-------------|
| `comet-common.names.base` | Returns the base chart name, using `nameOverride` if set. Truncated to 63 characters. |
| `comet-common.names.chart` | Returns `<chart-name>-<chart-version>` for use in chart labels. |
| `comet-common.names.name` | Returns the chart name, preferring `componentName` over `nameOverride`. |
| `comet-common.names.fullname` | Returns a fully qualified app name. Uses `fullnameOverride` if set, otherwise combines release name with chart name. |
| `comet-common.names.serviceAccount` | Returns the service account name. Uses `serviceAccount.name` if set, otherwise returns the fullname or "default". |

#### Usage

```yaml
metadata:
  name: {{ include "comet-common.names.fullname" . }}
```

### Labels

Helpers for generating Kubernetes labels following best practices.

| Helper | Description |
|--------|-------------|
| `comet-common.labels.component` | Returns the `app.kubernetes.io/component` label. |
| `comet-common.labels.base` | Returns base Kubernetes labels (name, chart, instance, managed-by, version). |
| `comet-common.labels` | Returns all common labels (base + component). |
| `comet-common.selectorLabels` | Returns selector labels for matching pods (name, instance, component). |

#### Usage

Simple usage with default context:

```yaml
metadata:
  labels:
    {{- include "comet-common.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "comet-common.selectorLabels" . | nindent 6 }}
```

Advanced usage with custom labels and component name:

```yaml
metadata:
  labels:
    {{- include "comet-common.labels" (dict "componentName" "api" "customLabels" .Values.commonLabels "context" $) | nindent 4 }}
```

### Images

Helpers for managing container images.

| Helper | Description |
|--------|-------------|
| `comet-common.images.image` | Returns the full image reference (registry/repository:tag or @digest). |
| `comet-common.images.pullSecrets` | Returns `imagePullSecrets` block from global and image-specific settings. |
| `comet-common.images.renderPullSecrets` | Same as above but evaluates values as templates. |
| `comet-common.images.version` | Returns the semantic version from the image tag, falling back to chart appVersion. |

#### Usage

```yaml
containers:
  - name: app
    image: {{ include "comet-common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) }}
    imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- include "comet-common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) | nindent 6 }}
```

#### Expected Values Structure

```yaml
global:
  imageRegistry: ""  # Optional global registry override
  imagePullSecrets: []

image:
  registry: docker.io
  repository: myapp/myimage
  tag: "1.0.0"
  digest: ""  # Optional, takes precedence over tag
  pullPolicy: IfNotPresent
  pullSecrets: []
```

### Size Presets

Helpers for managing resource presets across different deployment sizes.

| Helper | Description |
|--------|-------------|
| `comet-common.selectSizePreset` | Looks up a value from size presets based on component and path. |
| `comet-common.sizePresets.resources` | Returns a complete resources block using size presets with optional overrides. |

#### Usage

```yaml
resources:
  {{- include "comet-common.sizePresets.resources" (list "api" .Values.resources $) | nindent 2 }}
```

#### Expected Values Structure

```yaml
global:
  deploymentSizePreset: "small"  # or "medium", "large", etc.
  sizePresets:
    small:
      api:
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
    medium:
      api:
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
```

### Template Values

Helpers for rendering values that may contain Go templates.

| Helper | Description |
|--------|-------------|
| `comet-common.tplvalues.render` | Renders a value that may contain Go template syntax. |
| `comet-common.tplvalues.merge` | Merges multiple values (with template rendering) into one. |
| `comet-common.tplvalues.saferender` | Recursively renders templates in nested structures (dicts/lists). |

#### Usage

Render a single value:

```yaml
annotations:
  {{- include "comet-common.tplvalues.render" (dict "value" .Values.annotations "context" $) | nindent 4 }}
```

Render with a relative scope:

```yaml
{{- include "comet-common.tplvalues.render" (dict "value" .Values.config "context" $ "scope" .Values.app) }}
```

Merge multiple values:

```yaml
{{- include "comet-common.tplvalues.merge" (dict "values" (list .Values.defaultConfig .Values.customConfig) "context" $) | nindent 2 }}
```

Safely render nested structures:

```yaml
{{- include "comet-common.tplvalues.saferender" (dict "value" .Values.image "context" $) | nindent 2 }}
```

### Imported Bitnami Common Helpers

These helpers are ported from the (now unmaintained) Bitnami `common` library chart, renamed under
the `comet-common.*` namespace and adapted for this chart. They live in
[`templates/_imported_bitnami_common.tpl`](templates/_imported_bitnami_common.tpl). Helpers this chart
already provides (names, labels, images, tplvalues, affinities, size presets) were not re-imported.

#### Capabilities

Resolve the correct `apiVersion` / Kubernetes version for the target cluster.

| Helper | Description |
|--------|-------------|
| `comet-common.capabilities.kubeVersion` | Returns the target Kubernetes version. |
| `comet-common.capabilities.apiVersions.has` | Returns `true` if a given apiVersion is available. |
| `comet-common.capabilities.<kind>.apiVersion` | Returns the apiVersion for `policy`, `networkPolicy`, `job`, `cronjob`, `daemonset`, `deployment`, `statefulset`, `ingress`, `rbac`, `crd`, `apiService`, `hpa`, `vpa`. |
| `comet-common.capabilities.psp.supported` | Returns `true` when PodSecurityPolicy is supported (K8s < 1.25). |
| `comet-common.capabilities.admissionConfiguration.supported` / `.apiVersion` | AdmissionConfiguration support + version. |
| `comet-common.capabilities.podSecurityConfiguration.apiVersion` | PodSecurityConfiguration apiVersion. |
| `comet-common.capabilities.supportsHelmVersion` | Returns `true` if Helm is 3.3+. |

```yaml
apiVersion: {{ include "comet-common.capabilities.deployment.apiVersion" . }}
kind: Deployment
{{- if include "comet-common.capabilities.apiVersions.has" (dict "version" "batch/v1" "context" $) }}
# batch/v1 is available
{{- end }}
```

#### Names

| Helper | Description |
|--------|-------------|
| `comet-common.names.namespace` | Returns the release namespace, honoring `namespaceOverride`. |

#### Storage

| Helper | Description |
|--------|-------------|
| `comet-common.storage.class` | Resolves the storage class (global → persistence → global default), emitting the `storageClassName:` line. `"-"` yields an empty class name. |

```yaml
{{- include "comet-common.storage.class" (dict "persistence" .Values.persistence "global" .Values.global) | nindent 2 }}
```

#### Ingress

| Helper | Description |
|--------|-------------|
| `comet-common.ingress.backend` | Renders an Ingress backend block, choosing `port.name` vs `port.number` based on the value type. |
| `comet-common.ingress.certManagerRequest` | Returns `true` if cert-manager annotations are present. |

```yaml
backend:
  {{- include "comet-common.ingress.backend" (dict "serviceName" "my-svc" "servicePort" "http" "context" $) | nindent 2 }}
```

#### Utils

| Helper | Description |
|--------|-------------|
| `comet-common.utils.fieldToEnvVar` | Converts a field name to an env var name (`my-password` → `MY_PASSWORD`). |
| `comet-common.utils.getValueFromKey` | Reads a dot-path value out of `.Values`. |
| `comet-common.utils.getKeyFromList` | Returns the first key in a list that resolves to a defined value. |
| `comet-common.utils.secret.getvalue` | Prints a `kubectl get secret` one-liner to fetch and decode a secret value. |
| `comet-common.utils.checksumTemplate` | sha256sum of a rendered single-resource template (minus metadata) for pod annotations. |

#### Secrets

> Helpers using `lookup` (`secrets.passwords.manage`, `secrets.lookup`, `secrets.exists`) only see
> existing cluster state during `helm install`/`upgrade`, not `helm template`.

| Helper | Description |
|--------|-------------|
| `comet-common.secrets.name` | Resolves a secret name, honoring an `existingSecret` (string or object) and optional suffix. |
| `comet-common.secrets.key` | Resolves a secret key, applying `existingSecret.keyMapping` when present. |
| `comet-common.secrets.passwords.manage` | Returns an existing, provided, or freshly generated password (see ordering in the helper docstring). Fails a `helm upgrade` if a required password is empty. |
| `comet-common.secrets.lookup` | Reuses an existing secret value, else base64-encodes a default. |
| `comet-common.secrets.exists` | Returns `true` if the named secret already exists. |

#### Compatibility

| Helper | Description |
|--------|-------------|
| `comet-common.compatibility.isOpenshift` | Returns `true` when running on OpenShift. |
| `comet-common.compatibility.renderSecurityContext` | Renders a securityContext, stripping fields incompatible with OpenShift's restricted SCC when configured via `global.compatibility.openshift`. |

```yaml
securityContext:
  {{- include "comet-common.compatibility.renderSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) | nindent 2 }}
```

## License

Copyright Comet ML, Inc.

Portions of [`templates/_imported_bitnami_common.tpl`](templates/_imported_bitnami_common.tpl) are
adapted from the Bitnami `common` chart, Copyright Broadcom, Inc., licensed under Apache-2.0.
