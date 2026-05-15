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
│   ├── bash-scripting-basics/
│   │   ├── lab.yaml                # Lab definition
│   │   ├── validate_hello.sh       # Validation scripts (one per task)
│   │   ├── validate_calc.sh
│   │   └── validate_countdown.sh
│   ├── linux-sysadmin-intro/
│   │   ├── lab.yaml
│   │   ├── validate_user.sh
│   │   ├── validate_permissions.sh
│   │   ├── validate_process.sh
│   │   └── validate_disk.sh
│   └── docker-fundamentals/
│       ├── lab.yaml
│       ├── validate_nginx.sh
│       ├── validate_image.sh
│       ├── validate_volume.sh
│       └── validate_compose.sh
└── docs/
    └── images.md                   # Available container images & WASM environments
```

Each lab lives in its own folder. The platform picks up any file named `lab.yaml` (or `lab.yml`) inside any subdirectory of `labs/`.

---

## Lab types

| Type | `mode` value | Environment | Best for |
|------|-------------|-------------|----------|
| **WASM** | `wasm` | Browser-based Linux (Arch, no install needed) | Bash scripting, CLI tasks, quick assessments |
| **VDI Terminal** | `vdi_terminal` | Cloud Linux VM — terminal only | Server admin, DevOps, networking |
| **VDI Desktop** | `vdi_desktop` | Cloud Linux VM — full GUI desktop | IDE coding, data science, desktop tools |

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
    validation_script: labs/my-lab/validate.sh

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
  credit_price: 0   # 0 = free
```

```bash
# labs/my-lab/validate.sh
#!/bin/bash
[ -f /root/hello.txt ] || exit 1
grep -q "Hello" /root/hello.txt || exit 1
exit 0
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
    validation_script: labs/my-lab/validate_task.sh   # path from repo root
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

- Path is **relative to the repo root** (e.g. `labs/my-lab/validate.sh`)
- Must exit `0` on success, non-zero on failure
- Standard output is shown to the candidate if the task fails
- Keep scripts fast (under 5 s) — they run every time the candidate clicks **Check Tasks**

```bash
#!/bin/bash
# Example: check that a file exists and contains expected content
[ -f /root/result.txt ]          || { echo "FAIL: result.txt not found"; exit 1; }
grep -q "expected" /root/result.txt || { echo "FAIL: wrong content"; exit 1; }
exit 0
```

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

## Available images

See **[docs/images.md](docs/images.md)** for the full list of available container images for VDI terminal and desktop labs, including specialized images for DevOps, Python, Java, security, and more.

---

## Questions?

- Open an issue in this repo
- Contact support at [demo.skillcertify.io](https://demo.skillcertify.io)
- View your labs in the [Creator Studio](https://demo.skillcertify.io/talent/creator)
