# sample-devcontainers

A collection of ready-to-use development environments built on [Dev Containers](https://containers.dev/). Clone this repo, open the folder for the setup you need in VS Code, and your entire development environment — language runtimes, build tools, databases, and more — is automatically configured inside a container. Nothing extra gets installed on your machine.

## Available setups

| Folder | Stack | What's preinstalled |
|--------|-------|---------------------|
| [`web/`](web/) | Vue 3 + Spring Boot + PostgreSQL + Flyway | Node.js 24, JDK 25 + Maven, Docker-in-Docker, kubectl, Helm, Claude Code CLI |

New setups will appear as sibling folders alongside `web/`.

For a detailed description of the `web/` architecture, see [`web/docs/sample-architecture.md`](web/docs/sample-architecture.md).

---

## What is a devcontainer?

A devcontainer is a configuration file that tells VS Code how to build a Linux environment inside Docker. You write and edit code on your own machine as normal, but the code actually runs inside the container — so every developer on the team gets the same versions of every tool, on any OS, without any manual setup.

---

## Prerequisites

Before you can open a devcontainer you need three things installed on your machine.

### 1. Docker

**Windows**
- Download and install [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/).
- Windows 10 and 11 (including Home editions) are supported.
- The installer will prompt you to enable WSL 2 — accept this; it is required for Docker to work on Windows.
- After installation, start Docker Desktop and wait for the whale icon in the system tray to stop animating before continuing.

**Linux**
- Install [Docker Engine](https://docs.docker.com/engine/install/) for your distribution.
- After installation, add your user to the `docker` group so you can run Docker without `sudo`:
  ```bash
  sudo usermod -aG docker $USER
  newgrp docker
  ```
  If `newgrp` does not take effect, log out and back in.

### 2. Visual Studio Code

Download and install [VS Code](https://code.visualstudio.com/) for your operating system. The same page covers both Windows and Linux.

### 3. Dev Containers extension

Inside VS Code, open the Extensions panel (the icon on the left sidebar that looks like four squares, or press `Ctrl+Shift+X`), search for **Dev Containers**, and install the extension published by Microsoft (ID: `ms-vscode-remote.remote-containers`).

### 4. Git

You need Git to clone this repository.

- **Windows:** Download [Git for Windows](https://git-scm.com/download/win) and run the installer.
- **Linux:** Install via your package manager, for example:
  ```bash
  sudo apt install git        # Debian / Ubuntu
  sudo dnf install git        # Fedora / RHEL
  ```

---

## Quick start

1. **Get the files.** You have two options:

   - **Download the ZIP (simplest, no Git required):** Click the green **Code** button at the top of this page on GitHub, then choose **Download ZIP**. Extract the archive somewhere on your machine.
   - **Clone with Git:** Open a terminal (on Windows, use Git Bash or the Windows Terminal) and run:
     ```bash
     git clone https://github.com/NilsB98/sample-devcontainers.git
     ```

2. **Copy the subfolder you need** to wherever you want your project to live — for example, copy the `web/` folder to `~/projects/my-web-app`. This separates your work from this repository so you can develop freely without any connection back to it.

3. **Open VS Code.**

4. Choose **File → Open Folder…** and select the **copied subfolder** (e.g. `my-web-app`), not the original repository folder. Each subfolder has its own `.devcontainer/` configuration; opening a folder without one will not trigger the container setup.

5. VS Code will show a notification in the bottom-right corner:
   > **"Folder contains a Dev Container configuration file. Reopen folder to develop in a container."**

   Click **Reopen in Container**. If the notification disappears, you can also open the Command Palette (`Ctrl+Shift+P`) and run **Dev Containers: Reopen in Container**.

6. **Wait for the build to finish.** The first build downloads the base image and installs all tools — this usually takes a few minutes depending on your internet connection. Subsequent opens skip most of this and start in seconds.

7. When the build finishes, a terminal will open inside the container. The prompt will look something like:
   ```
   vscode@abc123456789:/workspaces/web$
   ```
   You are now working inside the container.

> **How to confirm it worked:** Look at the very bottom-left corner of the VS Code window. You will see a green label that says something like `Dev Container: Claude Code Dev`. As long as that label is visible, all terminals, extensions, and tools run inside the container.

---

## What you get in the `web/` container

| Tool | Version |
|------|---------|
| Operating system | Ubuntu 24.04 |
| Shell | zsh |
| Node.js | 24 LTS |
| JDK | 25 (Microsoft build) |
| Maven | latest |
| Docker | (Docker-in-Docker) |
| kubectl | latest |
| Helm | 3 |
| Claude Code CLI | latest |

The authoritative configuration is [`web/.devcontainer/devcontainer.json`](web/.devcontainer/devcontainer.json).

Your shell history and Claude Code authentication are stored in persistent Docker volumes, so they survive container rebuilds.

---

## For technical users: how these containers are built

Each devcontainer in this repository follows the same design principles:

- **No custom Dockerfile.** Every tool is composed from official [Dev Container Features](https://containers.dev/features), keeping the configuration declarative and easy to read.
- **Features pinned by OCI digest.** Each feature reference includes a `@sha256:…` digest so that rebuilds are fully reproducible and immune to upstream tag mutations.
- **Persistent named volumes** for stateful data (shell history, Claude config/auth) so that a `Rebuild Container` does not lose your session state.
- **`postCreateCommand`** handles one-time setup that cannot be expressed as a feature, such as the Claude Code CLI install.

The `web/` container is the canonical example: [`web/.devcontainer/devcontainer.json`](web/.devcontainer/devcontainer.json).

---

## Adding a new devcontainer

1. Create a new folder next to `web/` (e.g. `mobile/`, `data/`).
2. Inside it, create `.devcontainer/devcontainer.json`. Use [`web/.devcontainer/devcontainer.json`](web/.devcontainer/devcontainer.json) as a starting template.
3. Follow the same conventions: Features only (no Dockerfile), digest-pinned references, named volumes for persistent state.
4. Add a row for your new setup to the [Available setups](#available-setups) table in this README.

---

## Troubleshooting

**The "Reopen in Container" notification never appeared.**
Open the Command Palette (`Ctrl+Shift+P`) and run **Dev Containers: Reopen in Container** manually.

**Build fails with a Docker-related error on Windows.**
Make sure Docker Desktop is actually running — look for the whale icon in the Windows system tray. If it is not there, start Docker Desktop and wait until the icon stops animating before trying again.

**Build fails with a permission error on Linux.**
You most likely skipped the `docker` group step. Run `newgrp docker` in your terminal, or log out and back in, then try again.

**I opened the wrong folder and the container did not start.**
If you opened the repository root instead of a subfolder, there is no `.devcontainer/` at that level. Close the window and reopen using the correct subfolder (`web/`, etc.).

---

## Further reading

- [VS Code Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container specification](https://containers.dev/)
- [Dev Container Features registry](https://containers.dev/features)
- [web/ stack architecture](web/docs/sample-architecture.md)
