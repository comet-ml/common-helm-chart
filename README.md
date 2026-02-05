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

## License

Copyright Comet ML, Inc.
