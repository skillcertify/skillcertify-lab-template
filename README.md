# SkillCertify Lab Template

A starter repository for building and publishing technical assessment labs on [SkillCertify](https://demo.skillcertify.io).

Labs are YAML files that define a hands-on environment, tasks, and scoring rules. Once your lab is live, companies can assign it to candidates and you earn credits every time it's completed.

---

## How it works

```
Fork this repo  →  Add your lab in labs/<name>/  →  Push to GitHub  →  Import in Creator Studio  →  Admin reviews  →  Lab goes live
```

1. **Fork this repo** and create a folder inside `labs/` for each lab you want to build
2. **Write your lab** — a `lab.yaml` file and optional validation scripts (`.sh`) in the same folder
3. **Connect your GitHub repo** in [Creator Studio](https://demo.skillcertify.io/talent/creator) → "My Labs" → "Import from GitHub"
4. **Preview and sync** — the platform fetches every `lab.yaml` under `labs/` and shows a preview before importing
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
│   │   ├── lab.yaml
│   │   └── docs/
│   ├── python-data-analysis/          # WASM — free, beginner (pandas)
│   │   ├── lab.yaml
│   │   └── docs/
│   ├── linux-sysadmin-intro/          # VDI terminal — 1 credit, intermediate
│   │   ├── lab.yaml
│   │   └── docs/
│   ├── docker-fundamentals/           # VDI desktop — 2 credits, intermediate
│   │   ├── lab.yaml
│   │   └── docs/
│   ├── kubernetes-basics/             # VDI terminal + vCluster — 2 credits
│   │   ├── lab.yaml
│   │   ├── helm-values/
│   │   └── docs/
│   ├── sql-injection-fundamentals/    # VDI desktop + Juice Shop — 2 credits
│   │   ├── lab.yaml
│   │   ├── helm-values/
│   │   └── docs/
│   └── web-api-security/              # VDI desktop + Juice Shop + VAmPI sidecars
│       ├── lab.yaml
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

Each lab lives in its own folder. The platform picks up any file named `lab.yaml` (or `lab.yml`) inside any subdirectory of `labs/`.

---

## Lab types

| Type | `mode` value | Environment | Credits | Best for |
|------|-------------|-------------|---------|----------|
| **WASM** | `wasm` | Browser-based Linux (Arch, no install needed) | **Free** (always 0) | Bash scripting, CLI tasks, quick assessments |
| **VDI Terminal** | `vdi_terminal` | Cloud Linux VM — terminal only | Paid (≥ 1 credit) | Server admin, DevOps, networking |
| **VDI Desktop** | `vdi_desktop` | Cloud Linux VM — full GUI desktop | Paid (≥ 1 credit) | IDE coding, data science, desktop tools |

> **WASM labs are always free.** They run entirely in the candidate's browser with no cloud VM cost.
> **VDI labs cost credits** (set `marketplace.credit_price` ≥ 1). Free VDI labs are not supported.

See **[docs/images.md](docs/images.md)** for the full list of available container images and WASM environments.

---

## Quick example

```yaml
# labs/my-lab/lab.yaml
version: 1
title: "My First Lab"
slug: my-first-lab
description: "A short description shown on the lab card."
difficulty: beginner        # beginner | intermediate | advanced
mode: wasm                  # wasm | vdi_terminal | vdi_desktop
category: linux
skills: [bash, linux]
duration_minutes: 30
passing_score: 70

challenges:
  - id: task-1
    title: "Create a file"
    description: "Create /root/hello.txt containing the text 'Hello'."
    type: script
    points: 50
    validation_script: docs/validate.sh

  - id: task-2
    title: "What exit code means success?"
    type: single_choice
    points: 50
    options: ["0", "1", "127", "-1"]
    answer: "0"

scoring:
  passing_score: 70
  max_score: 100

marketplace:
  credit_price: 0   # WASM labs are always free — this value is ignored by the platform
```

```bash
# labs/my-lab/docs/validate.sh
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
| `title` | ✅ | string | Display name shown to candidates |
| `description` | ✅ | string | Short summary shown on the lab card |
| `difficulty` | ✅ | string | `beginner` / `intermediate` / `advanced` |
| `mode` | ✅ | string | `wasm`, `vdi_terminal`, or `vdi_desktop` |
| `duration_minutes` | ✅ | int | Time limit in minutes |
| `slug` | | string | URL-friendly ID (auto-generated from title if omitted) |
| `version` | | int | Schema version, use `1` |
| `category` | | string | e.g. `linux`, `docker`, `python`, `networking` |
| `skills` | | list | Skills validated by this lab |
| `tags` | | list | Extra searchable tags |
| `instructions` | | string | Markdown shown to the candidate at the start |
| `passing_score` | | int | Minimum score % to pass (default: `70`) |
| `credits` | | int | Credits a candidate spends (shorthand for `marketplace.credit_price`) |

### `environment` block

```yaml
environment:
  image: ghcr.io/skillcertify/vdi-terminal:latest   # VDI labs only
  wasm_image: skillcertify/archlinux-wasm:latest     # WASM labs only (optional)
  init_script: |
    # Bash commands run inside the VM before the lab starts
    apt-get install -y curl
```

### `challenges` list

```yaml
challenges:
  - id: unique-task-id         # must be unique within the lab
    title: "Task title"
    description: "What the candidate must do. Markdown supported."
    type: script               # see task types below
    points: 25
    validation_script: docs/validate_task.sh   # relative to this lab's folder
```

### Task types

| Type | How it's graded |
|------|----------------|
| `script` | Bash script runs inside the VM; exits `0` = pass |
| `single_choice` | Candidate picks one option; auto-graded against `answer` |
| `multiple_choice` | Candidate picks multiple options; auto-graded against `answer` list |
| `question` | Short text answer; compared against `answer` string |
| `question_ai` | Long-form answer; AI evaluates against `answer` as a rubric |
| `manual` | Company or admin reviewer grades it manually |

### `scoring` block

```yaml
scoring:
  passing_score: 70   # % required to pass
  max_score: 100
```

### `marketplace` block

```yaml
marketplace:
  credit_price: 2   # credits candidates spend; 0 = free
```

---

## Validation scripts

Scripts referenced in `validation_script` run inside the candidate's live environment.

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
5. Click **"Sync Labs"** — each `lab.yaml` becomes a draft lab in your account
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
# lab.yaml
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
- `environment.image` in `lab.yaml`
- `image:` fields in all `helm-values/*.yaml` files

The GitHub Actions workflow in `.github/workflows/validate-labs.yml` enforces this automatically on every push and pull request. Use images from **[docs/images.md](docs/images.md)** and chart values from **[docs/helm-charts.md](docs/helm-charts.md)** — they are already whitelisted.

---

## Questions?

- Open an issue in this repo
- Contact support at [demo.skillcertify.io](https://demo.skillcertify.io)
- View your labs in the [Creator Studio](https://demo.skillcertify.io/talent/creator)
