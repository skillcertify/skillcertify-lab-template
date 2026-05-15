# Available Helm Charts

VDI labs use `helm_packages` to deploy the lab environment. Every VDI lab needs at
least the **workspace** chart (which provisions the VDI container). You can add
extra charts to deploy target services alongside the desktop.

All SkillCertify charts are published at **`oci://ghcr.io/skillcertify`**.

---

## How helm_packages work

```yaml
# In lab.yaml
helm_packages:
  - name: workspace                          # Helm release name (must be unique per lab)
    helm_repository: $HELM_LOCAL_REPO_PATH   # Use this exact value for the workspace chart
    helm_package_name: workspace
    helm_package_version: ""                 # Empty = latest
    helm_values_path: helm-values/workspace.yaml

  - name: my-target-service
    helm_repository: oci://ghcr.io/skillcertify
    helm_package_name: owasp-juice-shop
    helm_package_version: "0.1.0"
    helm_values_path: helm-values/owasp-juice-shop.yaml
```

Each entry in `helm_packages` deploys one Helm release into the candidate's
isolated namespace. Sidecar services are reachable from the VDI by their
Helm release `name` as the DNS hostname (e.g. `http://owasp-juice-shop:3000`).

---

## workspace chart (required for all VDI labs)

The workspace chart provisions the VDI container itself.

**`helm_repository`:** `$HELM_LOCAL_REPO_PATH` (always use this exact value)
**`helm_package_name`:** `workspace`

### `helm-values/workspace.yaml` — all available fields

```yaml
vdi:
  image: ghcr.io/skillcertify/vdi-xfce-ubuntu   # VDI image (see docs/images.md)
  tag: latest
  imagePullPolicy: Always
  permissions:
    root: false           # true = run as root inside the container
  resources:
    requests:
      cpu: 300m
      memory: 1024Mi
    limits:
      cpu: 1000m
      memory: 3072Mi
  vnc_resolution: "1920x1080"
  idle_timeout_secs: "300"   # disconnect candidate after N seconds of inactivity
  init_script: |
    #!/bin/bash
    # Commands run as root before the candidate sees the environment
    apt-get install -y my-tool

# Optional: record the VNC session to a video file
recorder:
  enabled: false
  recording_path: "/home/ubuntu/recording.webm"
  fps: "15"

# Optional: give the candidate their own isolated Kubernetes cluster
vcluster:
  enabled: false

# Optional: monitor and log DNS queries for anti-fraud detection
monitor:
  dns:
    enabled: true
```

---

## owasp-juice-shop

A deliberately vulnerable Node.js e-commerce application covering OWASP Top 10.

**`helm_repository`:** `oci://ghcr.io/skillcertify`
**`helm_package_name`:** `owasp-juice-shop`
**`helm_package_version`:** `0.1.0`
**Default URL inside the lab:** `http://owasp-juice-shop:3000`

```yaml
# helm-values/owasp-juice-shop.yaml
owasp_juice_shop:
  image: ghcr.io/skillcertify/owasp-juice-shop
  tag: latest
  pullPolicy: IfNotPresent
  replicas: 1
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 400m
      memory: 512Mi
```

**Use for:** SQLi, XSS, broken auth, IDOR, security misconfiguration labs.

---

## vampi

A deliberately vulnerable Flask REST API covering OWASP API Security Top 10.

**`helm_repository`:** `oci://ghcr.io/skillcertify`
**`helm_package_name`:** `vampi`
**`helm_package_version`:** `0.1.0`
**Default URL inside the lab:** `http://vampi:5000`

```yaml
# helm-values/vampi.yaml
vampi:
  image: ghcr.io/skillcertify/vampi
  tag: latest
  pullPolicy: IfNotPresent
  replicas: 1
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
```

**Use for:** API authentication bypass, BOLA/IDOR, mass assignment, injection labs.

---

## gitea

A self-hosted Git server (Gitea). Use it when your lab involves source code review,
CI/CD pipelines, or secret scanning.

**`helm_repository`:** `oci://ghcr.io/skillcertify`
**`helm_package_name`:** `gitea`
**Default URL inside the lab:** `http://gitea:3000`

```yaml
# helm-values/gitea.yaml
gitea:
  image: ghcr.io/skillcertify/gitea
  tag: latest
  pullPolicy: IfNotPresent
  replicas: 1
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 300m
      memory: 512Mi
```

---

## dummyjson

A lightweight mock JSON REST API. Use it as a simple HTTP target or data source
for labs that don't need a full vulnerable app.

**`helm_repository`:** `oci://ghcr.io/skillcertify`
**`helm_package_name`:** `dummyjson`
**Default URL inside the lab:** `http://dummyjson:3000`

```yaml
# helm-values/dummyjson.yaml
dummyjson:
  image: ghcr.io/skillcertify/dummyjson
  tag: latest
  pullPolicy: IfNotPresent
  replicas: 1
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 100m
      memory: 128Mi
```

---

## Combining multiple charts — example

```yaml
# lab.yaml
helm_packages:
  - name: workspace
    helm_repository: $HELM_LOCAL_REPO_PATH
    helm_package_name: workspace
    helm_package_version: ""
    helm_values_path: helm-values/workspace.yaml

  - name: owasp-juice-shop
    helm_repository: oci://ghcr.io/skillcertify
    helm_package_name: owasp-juice-shop
    helm_package_version: "0.1.0"
    helm_values_path: helm-values/owasp-juice-shop.yaml

  - name: vampi
    helm_repository: oci://ghcr.io/skillcertify
    helm_package_name: vampi
    helm_package_version: "0.1.0"
    helm_values_path: helm-values/vampi.yaml
```

Inside the VDI, targets are reachable at:
- `http://owasp-juice-shop:3000`
- `http://vampi:5000`

See [`labs/web-api-security/`](../labs/web-api-security/) for a working example.

---

## DNS hostname convention

The DNS hostname of each sidecar service is the Helm **release name** (the `name`
field in `helm_packages`), not the chart name. So if you name your release
`my-target`, the VDI can reach it at `http://my-target:<port>`.

---

## Open-source attribution

The sidecar service images are based on the following open-source projects, all
licensed under the **MIT License**:

| Chart | Upstream project | License |
|-------|-----------------|---------|
| `owasp-juice-shop` | [OWASP Juice Shop](https://github.com/juice-shop/juice-shop) — © Björn Kimminich | MIT |
| `vampi` | [VAmPI](https://github.com/erev0s/VAmPI) — © erev0s | MIT |
| `gitea` | [Gitea](https://github.com/go-gitea/gitea) — © The Gitea Authors | MIT |
| `dummyjson` | [DummyJSON](https://github.com/Ovi/DummyJSON) — © Ovi | MIT |

SkillCertify re-publishes these images to its own registry (`ghcr.io/skillcertify/`) for
controlled distribution. Original copyright notices and MIT license texts are preserved
inside each image at `/usr/share/doc/<package>/LICENSE`.
