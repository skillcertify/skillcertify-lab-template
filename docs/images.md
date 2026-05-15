# Available Container Images & Environments

All images are hosted at **`ghcr.io/skillcertify/`** and are publicly available.

---

## WASM Labs (`mode: wasm`)

WASM labs run entirely in the candidate's browser using a Linux virtual machine
powered by [v86](https://github.com/copy/v86). No cloud infrastructure is needed.

The platform provides a single built-in Arch Linux environment. You do not need
to specify a custom image — leave `wasm_image` unset or omit the `environment` block.

```yaml
mode: wasm
# No environment block needed — the platform provides the Arch Linux VM
```

**Pre-installed packages:** bash, coreutils, grep, sed, gawk, python3, curl, git, vim

**Limitations:**
- No systemd, no Docker, no VNC
- Suitable for CLI scripting, file manipulation, and basic network tools
- Candidates cannot install packages that require kernel modules

---

## VDI Terminal Labs (`mode: vdi_terminal`)

A minimal cloud Linux VM with a terminal interface only (no desktop GUI).
Candidates connect via an in-browser terminal (xterm).

### Base image

| Image | Description |
|-------|-------------|
| `ghcr.io/skillcertify/vdi-terminal:latest` | Ubuntu 24.04, bash, curl, git, vim, net-tools |

**Use this for:** CLI tooling, server administration, scripting, networking, DevOps.

```yaml
mode: vdi_terminal
environment:
  image: ghcr.io/skillcertify/vdi-terminal:latest
  init_script: |
    apt-get install -y -qq <your-packages>
```

---

## VDI Desktop Labs (`mode: vdi_desktop`)

A full Linux desktop environment accessible via noVNC in the browser.
Includes XFCE, VNC, VS Code, and Firefox.

### Base image

| Image | Description |
|-------|-------------|
| `ghcr.io/skillcertify/vdi-xfce-ubuntu:latest` | Ubuntu 24.04 + XFCE desktop, noVNC, VS Code, Firefox |

### Specialized images (extend the base)

| Image | Extra tools |
|-------|-------------|
| `ghcr.io/skillcertify/vdi-xfce-ubuntu-devops:latest` | Terraform, Docker, AWS CLI, Azure CLI, GCP CLI, Ansible, kubectl, Helm |
| `ghcr.io/skillcertify/vdi-xfce-ubuntu-python:latest` | Python 3, numpy, pandas, scikit-learn, Jupyter Lab |
| `ghcr.io/skillcertify/vdi-xfce-ubuntu-java:latest` | OpenJDK 17, Maven, Gradle, IntelliJ CE |
| `ghcr.io/skillcertify/vdi-xfce-ubuntu-nextjs:latest` | Node.js LTS, npm, React, Next.js, Vite |
| `ghcr.io/skillcertify/vdi-xfce-ubuntu-angular:latest` | Node.js LTS, Angular CLI |
| `ghcr.io/skillcertify/vdi-xfce-ubuntu-security:latest` | nmap, Metasploit, Hydra, sqlmap, Burp Suite CE, Wireshark |
| `ghcr.io/skillcertify/vdi-xfce-ubuntu-qa:latest` | Playwright, Selenium, pytest, Postman |

**Use these when** your lab needs a GUI, an IDE, or complex toolchains that are
hard to install quickly in `init_script`.

```yaml
mode: vdi_desktop
environment:
  image: ghcr.io/skillcertify/vdi-xfce-ubuntu-devops:latest
  init_script: |
    # Additional setup — runs at lab start inside the container
    mkdir -p /home/candidate/project
```

---

## Using `init_script`

The `init_script` runs as `root` inside the container after it starts but before
the candidate sees the environment. Use it to:

- Install additional packages
- Create files or directories
- Set up a starting state for the lab
- Download datasets or starter code

**Keep `init_script` fast** (under 30 s ideally). If your setup is heavy,
prefer a specialized image or pre-bake a custom image based on one of the above.

```yaml
environment:
  image: ghcr.io/skillcertify/vdi-xfce-ubuntu-python:latest
  init_script: |
    pip install -q faker faker-datasets
    mkdir -p /home/candidate/data
    python3 -c "
import json, random
data = [{'id': i, 'score': random.randint(0,100)} for i in range(50)]
open('/home/candidate/data/scores.json','w').write(json.dumps(data))
"

---

## Building a custom image

If none of the available images fit your lab, you can build a custom one based on
any of the images above:

```dockerfile
# Dockerfile
FROM ghcr.io/skillcertify/vdi-xfce-ubuntu:latest

RUN apt-get update && apt-get install -y \
    my-tool-1 my-tool-2 \
    && rm -rf /var/lib/apt/lists/*

COPY my-config /etc/my-config
```

Push it to any public registry (e.g. `ghcr.io/<yourorg>/my-custom-vdi:latest`)
and reference it in your lab's `environment.image` field.

> **Note:** Custom images must expose VNC on port 5900 (VDI desktop) or a shell
> on stdin (VDI terminal) to work with the SkillCertify platform. Basing your
> image on one of the official images above is the easiest way to ensure this.

---

## Local testing with Docker

All official VDI images are public — you can pull and run them locally to test
your `init_script`, check that packages install correctly, or inspect the desktop
before publishing your lab.

### VDI Terminal (headless shell)

```bash
docker pull ghcr.io/skillcertify/vdi-terminal:latest
docker run -it --rm ghcr.io/skillcertify/vdi-terminal:latest bash
```

Once inside, run your `init_script` commands manually to verify they work.

### VDI Desktop (noVNC in browser)

```bash
docker pull ghcr.io/skillcertify/vdi-xfce-ubuntu:latest
docker run -d --rm \
  -p 6080:6080 \
  --name vdi-test \
  ghcr.io/skillcertify/vdi-xfce-ubuntu:latest
```

Open **http://localhost:6080** in your browser — you will see the full XFCE
desktop served via noVNC. Use the same port for any specialized image:

```bash
# DevOps image with Terraform, kubectl, Docker pre-installed
docker run -d --rm -p 6080:6080 --name vdi-devops \
  ghcr.io/skillcertify/vdi-xfce-ubuntu-devops:latest

# Python / data science image
docker run -d --rm -p 6080:6080 --name vdi-python \
  ghcr.io/skillcertify/vdi-xfce-ubuntu-python:latest

# Security image (nmap, sqlmap, Burp Suite CE…)
docker run -d --rm -p 6080:6080 --name vdi-security \
  ghcr.io/skillcertify/vdi-xfce-ubuntu-security:latest
```

Stop the container when done:

```bash
docker stop vdi-test
```
