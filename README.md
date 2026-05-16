# SkillCertify Lab Template

A starter repository for building and publishing technical assessment labs on [SkillCertify](https://demo.skillcertify.io).

Labs are YAML files that define a hands-on environment, tasks, and scoring rules. Once your lab is live, companies can assign it to candidates and you earn credits every time it's completed.

---

## How it works

```
Fork this repo  →  Add your lab in labs/<name>/  →  Push to GitHub  →  Import in Creator Studio  →  Admin reviews  →  Lab goes live
```

1. **Fork this repo** and create a folder inside `labs/` for each lab you want to build
2. **Write your lab** — a `metadata.yml` file and optional validation scripts (`.sh`) in the same folder
3. **Connect your GitHub repo** in [Creator Studio](https://demo.skillcertify.io/talent/creator) → "My Labs" → "Import from GitHub"
4. **Preview and sync** — the platform fetches every `metadata.yml` under `labs/` and shows a preview before importing
5. **Wait for approval** — the SkillCertify team reviews new labs (usually within 24–48 h)
6. **Earn credits** — you receive 30% of the credit price every time a candidate completes your lab

---

## Prerequisites

- A SkillCertify creator account at [demo.skillcertify.io/talent/creator](https://demo.skillcertify.io/talent/creator)
- A GitHub account (public repos work without a token; private repos need a GitHub PAT)
- Identity verification approved by the SkillCertify team (contact support to start)

---

## Repository structure

```
skillcertify-lab-template/
├── labs/
│   ├── bash-scripting-basics/         # WASM — free, beginner
│   │   ├── metadata.yml
│   │   └── docs/
│   ├── python-data-analysis/          # WASM — free, beginner (pandas)
│   │   ├── metadata.yml
│   │   └── docs/
│   ├── linux-sysadmin-intro/          # VDI terminal — 1 credit, intermediate
│   │   ├── metadata.yml
│   │   ├── helm-values/
│   │   └── docs/
│   ├── docker-fundamentals/           # VDI desktop — 2 credits, intermediate
│   │   ├── metadata.yml
│   │   ├── helm-values/
│   │   └── docs/
│   ├── kubernetes-basics/             # VDI terminal + vCluster — 2 credits
│   │   ├── metadata.yml
│   │   ├── helm-values/
│   │   └── docs/
│   ├── sql-injection-fundamentals/    # VDI desktop + Juice Shop — 2 credits
│   │   ├── metadata.yml
│   │   ├── helm-values/
│   │   └── docs/
│   └── web-api-security/              # VDI desktop + Juice Shop + VAmPI sidecars
│       ├── metadata.yml
│       ├── helm-values/            # One values file per Helm release
│       │   ├── workspace.yaml
│       │   ├── owasp-juice-shop.yaml
│       │   └── vampi.yaml
│       └── docs/
│           ├── validate_sqli.sh
│           ├── validate_api_bypass.sh
│           └── validate_bola.sh
├── docs/
│   ├── images.md                   # Available VDI container images & WASM environments
│   └── helm-charts.md              # Available Helm charts (sidecar services)
└── .github/
    └── workflows/
        └── validate-labs.yml       # CI: enforces image whitelist + structure checks
```

Each lab lives in its own folder. The platform picks up any file named `metadata.yml` inside any subdirectory of `labs/`.

---

## Lab types

| Type | `environment_type` value | Environment | Credits | Best for |
|------|--------------------------|-------------|---------|----------|
| **WASM** | `wasm` | Browser-based Linux VM (no cloud needed) | **Free** (always 0) | Bash scripting, CLI tasks, quick assessments |
| **VDI Terminal** | `vdi_terminal` | Cloud Linux VM — terminal only | Paid (≥ 1 credit) | Server admin, DevOps, networking |
| **VDI Desktop** | `vdi_desktop` | Cloud Linux VM — full GUI desktop | Paid (≥ 1 credit) | IDE coding, data science, desktop tools |

> **WASM labs are always free.** They run entirely in the candidate's browser with no cloud VM cost.
> **VDI labs cost credits** (set `credits` ≥ 1). Free VDI labs are not supported.

See **[docs/images.md](docs/images.md)** for the full list of available container images and WASM environments.

---

## Quick example

```yaml
# labs/my-lab/metadata.yml
version: 1
name: my-first-lab
title: My First Lab
language: english
category: linux
uuid: 00000000-0000-0000-0000-000000000000   # generate with: python3 -c "import uuid; print(uuid.uuid4())"
credits: 0
description: A short description shown on the lab card.
difficulty: beginner        # beginner | intermediate | advanced
environment_type: wasm      # wasm | vdi_terminal | vdi_desktop
wasm_image: linux           # WASM labs only; omit for VDI
skills_to_check:
  - bash
  - linux
tags:
  - bash
  - beginner
time: 1800                  # seconds (1800 = 30 min)
passing_score: 70
init_script: |              # WASM only — runs inside the browser VM before lab starts
  #!/bin/bash
  mkdir -p ~/workspace
  echo "Ready."
docs:
  title: My First Lab
  details:
    intro:
      content: |
        Welcome! Complete the tasks below using the terminal.
    questions:
      - type: script
        title: "Create a file"
        content: "Create /root/hello.txt containing the text 'Hello'."
        answer: docs/verify/task-001.sh
        points: 100
```

```bash
# labs/my-lab/docs/verify/task-001.sh
#!/bin/bash
[ -f /root/hello.txt ] || { echo '{"pass":false,"message":"Create /root/hello.txt first."}'; exit 0; }
grep -q "Hello" /root/hello.txt || { echo '{"pass":false,"message":"hello.txt must contain the word Hello."}'; exit 0; }
echo '{"pass":true,"message":"Task completed correctly."}'
```

---

## YAML field reference

### Top-level fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | ✅ | string | Unique lab slug — must match the folder name under `labs/` |
| `title` | ✅ | string | Display name shown to candidates |
| `description` | ✅ | string | Short summary shown on the lab card |
| `difficulty` | ✅ | string | `beginner` / `intermediate` / `advanced` |
| `environment_type` | ✅ | string | `wasm`, `vdi_terminal`, or `vdi_desktop` |
| `credits` | ✅ | int | Credits a candidate spends; WASM must be `0`, VDI must be ≥ 1 |
| `time` | ✅ | int | Time limit in **seconds** (e.g. `1800` = 30 min) |
| `version` | | int | Schema version — use `1` |
| `language` | | string | `english` (default) |
| `uuid` | | string | Stable UUID for this lab — generate once, never change |
| `category` | | string | e.g. `linux`, `devops`, `python`, `security` |
| `skills_to_check` | | list | Skills validated by this lab |
| `tags` | | list | Extra searchable tags |
| `passing_score` | | int | Minimum score % to pass (default: `70`) |
| `wasm_image` | | string | WASM labs only — always `linux` |
| `init_script` | | string | WASM labs only — bash script run in the VM before the lab starts |

### `docs` block

```yaml
docs:
  title: My Lab Title
  details:
    intro:
      content: |
        Markdown shown to the candidate at the start of the lab.
    questions:
      - type: script
        title: "Task title"
        content: "What the candidate must do. Markdown supported."
        answer: docs/verify/task-001.sh   # path relative to this lab's folder
        points: 25
```

### Task types

| Type | How it's graded |
|------|----------------|
| `script` | Bash script runs inside the VM; must exit `0` to pass — the only supported type |

### VDI labs — `helm-values/workspace.yaml`

For VDI labs the container image and init script go in `helm-values/workspace.yaml`, **not** in `metadata.yml`:

```yaml
# helm-values/workspace.yaml
vdi:
  image: ghcr.io/skillcertify/vdi-terminal   # or vdi-xfce-ubuntu for desktop
  tag: latest
  imagePullPolicy: Always
  permissions:
    root: true
  init_script: |
    #!/bin/bash
    apt-get install -y -qq your-package
```

---

## Validation scripts

Scripts referenced in `answer` run inside the candidate's live environment.

- Path is **relative to the lab folder** (e.g. `docs/validate_user.sh` resolves to `labs/my-lab/docs/validate_user.sh`)
- Put scripts inside a `docs/` subfolder — this matches the convention used in the official SkillCertify labs repo
- Scripts must **always exit 0** and print a JSON result to stdout
- Keep scripts fast (under 5 s) — they run every time the candidate clicks **Check Tasks**

```bash
#!/bin/bash
# docs/validate_task.sh — always exit 0, output JSON

[ -f /root/result.txt ] || {
  echo '{"pass":false,"message":"result.txt not found. Run: echo done > /root/result.txt"}'
  exit 0
}

grep -q "expected" /root/result.txt || {
  echo '{"pass":false,"message":"result.txt does not contain the expected text."}'
  exit 0
}

echo '{"pass":true,"message":"Task completed correctly."}'
```

The `message` is shown to the candidate in the task panel — make it actionable (tell them what to run to fix it).

---

## Importing into Creator Studio

1. Go to [demo.skillcertify.io/talent/creator](https://demo.skillcertify.io/talent/creator)
2. In the **My Labs** tab, click **"Import from GitHub"**
3. Enter your repository (e.g. `youruser/skillcertify-lab-template`), branch (`main`), and optionally a GitHub token for private repos
4. Click **"Preview Labs"** to review what will be imported
5. Click **"Sync Labs"** — each `metadata.yml` becomes a draft lab in your account
6. The SkillCertify team reviews and publishes approved labs

After publishing, your lab appears in the marketplace. The **Creator Dashboard** tab shows earnings, execution counts, and payout status.

---

## Re-syncing after changes

Push your changes to GitHub, then go back to Creator Studio → "Import from GitHub" → **"Sync Labs"**. Existing labs are updated; new folders create new draft labs.

---

## Available images and sidecar services

- **[docs/images.md](docs/images.md)** — VDI container images (terminal + desktop, 9 flavours)
- **[docs/helm-charts.md](docs/helm-charts.md)** — Helm charts you can add as sidecar services (Juice Shop, VAmPI, Gitea, DummyJSON)

---

## Sidecar services (helm_packages)

VDI labs can deploy additional services alongside the desktop using `helm_packages`. Each sidecar runs in the same isolated namespace and is reachable via its Helm release name as a DNS hostname.

```yaml
# metadata.yml
helm_packages:
  - name: workspace                        # required for all VDI labs
    helm_repository: $HELM_LOCAL_REPO_PATH
    helm_package_name: workspace
    helm_package_version: ""
    helm_values_path: helm-values/workspace.yaml

  - name: owasp-juice-shop                 # reachable at http://owasp-juice-shop:3000
    helm_repository: oci://ghcr.io/skillcertify
    helm_package_name: owasp-juice-shop
    helm_package_version: "0.1.0"
    helm_values_path: helm-values/owasp-juice-shop.yaml
```

See the `labs/web-api-security/` example for a working multi-chart lab. Full chart documentation is in **[docs/helm-charts.md](docs/helm-charts.md)**.

---

## Container image policy

> **Only images from `ghcr.io/skillcertify/` are permitted.**

Labs that reference images from any other registry will be rejected at import time and will fail CI. This applies to:
- `vdi.image` in `helm-values/workspace.yaml`
- `image:` fields in all `helm-values/*.yaml` files

The GitHub Actions workflow in `.github/workflows/validate-labs.yml` enforces this automatically on every push and pull request. Use images from **[docs/images.md](docs/images.md)** and chart values from **[docs/helm-charts.md](docs/helm-charts.md)** — they are already whitelisted.

---

## Questions?

- Open an issue in this repo
- Contact support at [demo.skillcertify.io](https://demo.skillcertify.io)
- View your labs in the [Creator Studio](https://demo.skillcertify.io/talent/creator)
