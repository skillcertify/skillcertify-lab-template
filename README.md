# SkillCertify Lab Template

A starter repository for building and publishing technical assessment labs on [SkillCertify](https://demo.skillcertify.io).

Labs are YAML files that define a hands-on environment, tasks, and scoring rules. Once your lab is live, companies can assign it to candidates and you earn credits every time it's completed.

---

## How it works

```
You write a YAML file  →  Push to GitHub  →  Import from Creator Studio  →  Admin reviews  →  Lab goes live
```

1. **Fork this repo** and add your own lab files inside the `labs/` directory
2. **Connect your GitHub repo** in [Creator Studio](https://demo.skillcertify.io/talent/creator) → "My Labs" → "Import from GitHub"
3. **Preview and sync** — the platform fetches all `.yaml` files from `labs/` and shows you a preview before importing
4. **Wait for approval** — the SkillCertify team reviews new labs (usually within 24–48 h)
5. **Earn credits** — you receive 30% of the credit price every time a candidate completes your lab

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
│   ├── bash-scripting-basics.yaml      # WASM lab — runs in the browser, zero server cost
│   ├── linux-sysadmin-intro.yaml       # VDI terminal lab — full Linux VM in the cloud
│   └── docker-fundamentals.yaml        # VDI desktop lab — GUI desktop environment
└── docs/
    └── verify_task.sh                  # Example bash validation script referenced by labs
```

All files inside `labs/` whose name ends in `.yaml` or `.yml` are picked up automatically by the sync.

---

## Lab types

| Type | Field value | Environment | Best for |
|------|-------------|-------------|----------|
| **WASM** | `mode: wasm` | Browser-based Linux (v86) | Quick tasks, scripting, no GUI needed |
| **VDI Terminal** | `mode: vdi_terminal` | Cloud Linux VM (terminal only) | CLI tools, server admin, DevOps |
| **VDI Desktop** | `mode: vdi_desktop` | Cloud Linux VM (full GUI) | IDE-based coding, desktop tools |

---

## YAML field reference

Every lab file lives in `labs/` and must be valid YAML. The fields below are all supported.

### Required fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Display name shown to candidates |
| `description` | string | Short description (shown on the lab card) |
| `difficulty` | string | `beginner` / `intermediate` / `advanced` |
| `mode` | string | `wasm`, `vdi_terminal`, or `vdi_desktop` |
| `duration_minutes` | int | Time limit in minutes |

### Optional but recommended

| Field | Type | Description |
|-------|------|-------------|
| `slug` | string | URL-friendly ID (auto-generated from title if omitted) |
| `category` | string | e.g. `linux`, `docker`, `python`, `networking` |
| `skills` | list | Skills this lab validates |
| `tags` | list | Extra searchable tags |
| `instructions` | string | Markdown shown to the candidate at the start |
| `passing_score` | int | Minimum score % to pass (default: 70) |

### Credit pricing

| Field | Type | Description |
|-------|------|-------------|
| `credits` | int | Credits a candidate spends to run this lab (0 = free) |

### Environment (WASM labs)

```yaml
environment:
  wasm_image: skillcertify/archlinux-wasm:latest  # WASM disk image
  init_script: |
    # Commands run inside the VM before the lab starts
    pacman -Sy --noconfirm curl git
```

### Environment (VDI labs)

```yaml
environment:
  image: skillcertify/ubuntu-vdi:22.04   # Docker image for the VDI container
  init_script: |
    # Commands run inside the container at startup
    apt-get install -y curl
```

### Tasks / Challenges

Candidates complete tasks that are scored automatically or manually.

```yaml
challenges:
  - id: task-1
    title: "Create a user"
    description: "Create a system user named 'deploy' with a home directory."
    type: script           # see task types below
    points: 25
    validation_script: docs/verify_task.sh   # path to a bash script in this repo

  - id: task-2
    title: "What signal terminates a process?"
    type: multiple_choice
    points: 10
    options:
      - SIGTERM
      - SIGKILL
      - SIGHUP
      - SIGSTOP
    answer:
      - SIGTERM
      - SIGKILL
```

#### Task types

| Type | How it's scored |
|------|----------------|
| `script` | A bash script runs inside the VM and exits 0 on pass |
| `multiple_choice` | Candidate picks one option; auto-graded |
| `single_choice` | Same as above, single answer |
| `question` | Short text answer; compared against `answer` field |
| `question_ai` | Long-form answer; AI evaluates against `answer` as rubric |
| `manual` | Admin or company reviewer grades it |

### Scoring block

```yaml
scoring:
  passing_score: 70    # % required to pass
  max_score: 100
```

### Marketplace block

```yaml
marketplace:
  credit_price: 2      # credits candidates spend (overrides top-level `credits`)
```

---

## Full examples

See the `labs/` directory:

- [`labs/bash-scripting-basics.yaml`](labs/bash-scripting-basics.yaml) — WASM, free, beginner
- [`labs/linux-sysadmin-intro.yaml`](labs/linux-sysadmin-intro.yaml) — VDI terminal, 1 credit, intermediate
- [`labs/docker-fundamentals.yaml`](labs/docker-fundamentals.yaml) — VDI desktop, 2 credits, intermediate

---

## Importing into Creator Studio

1. Go to [demo.skillcertify.io/talent/creator](https://demo.skillcertify.io/talent/creator)
2. Click **"My Labs"** → **"Import from GitHub"**
3. Enter your repository (`youruser/skillcertify-lab-template`), branch (`main`), and optionally a GitHub token for private repos
4. Click **"Preview Labs"** to see what will be imported
5. Click **"Sync Labs"** to import — labs are created with `draft` status
6. The SkillCertify team reviews and publishes approved labs

Once a lab is published, it appears in the marketplace and you can see earnings in the **Creator Dashboard** tab.

---

## Re-syncing after changes

After you push changes to a lab YAML, go back to Creator Studio → "Import from GitHub" and click **"Sync Labs"** again. Existing labs are updated; new files create new draft labs.

---

## Validation script format

Scripts referenced in `validation_script` receive no arguments and must exit `0` on success, non-zero on failure. They run inside the candidate's live environment.

```bash
#!/bin/bash
# docs/verify_task.sh — example
id deploy &>/dev/null || exit 1
[ -d /home/deploy ] || exit 1
exit 0
```

---

## Questions?

- Open an issue in this repo
- Contact support via [demo.skillcertify.io](https://demo.skillcertify.io)
- Read the creator docs at [demo.skillcertify.io/talent/creator](https://demo.skillcertify.io/talent/creator)
