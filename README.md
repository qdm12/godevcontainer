# Go Dev Container

**Ultimate Go development container for Visual Studio Code**

[![godevcontainer](https://github.com/qdm12/godevcontainer/raw/master/title.png)](https://hub.docker.com/r/qmcgaw/godevcontainer)

[![Alpine](https://github.com/qdm12/godevcontainer/actions/workflows/alpine.yml/badge.svg)](https://github.com/qdm12/godevcontainer/actions/workflows/alpine.yml)
[![Debian](https://github.com/qdm12/godevcontainer/actions/workflows/debian.yml/badge.svg)](https://github.com/qdm12/godevcontainer/actions/workflows/debian.yml)

[![dockeri.co](https://dockeri.co/image/qmcgaw/godevcontainer)](https://hub.docker.com/r/qmcgaw/godevcontainer)

![Last Docker tag](https://img.shields.io/docker/v/qmcgaw/godevcontainer?sort=semver&label=Last%20Docker%20tag)
[![Latest size](https://img.shields.io/docker/image-size/qmcgaw/godevcontainer/latest?label=Latest%20image)](https://hub.docker.com/r/qmcgaw/godevcontainer/tags)

![Last release](https://img.shields.io/github/release/qdm12/godevcontainer?label=Last%20release)
[![Last release size](https://img.shields.io/docker/image-size/qmcgaw/godevcontainer?sort=semver&label=Last%20released%20image)](https://hub.docker.com/r/qmcgaw/godevcontainer/tags?page=1&ordering=last_updated)
![GitHub last release date](https://img.shields.io/github/release-date/qdm12/godevcontainer?label=Last%20release%20date)
![Commits since release](https://img.shields.io/github/commits-since/qdm12/godevcontainer/latest?sort=semver)

[![GitHub last commit](https://img.shields.io/github/last-commit/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/commits/main)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/graphs/contributors)
[![GitHub closed PRs](https://img.shields.io/github/issues-pr-closed/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/pulls?q=is%3Apr+is%3Aclosed)
[![GitHub issues](https://img.shields.io/github/issues/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub closed issues](https://img.shields.io/github/issues-closed/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues?q=is%3Aissue+is%3Aclosed)

[![Lines of code](https://img.shields.io/tokei/lines/github/qdm12/godevcontainer)](https://github.com/qdm12/godevcontainer)
![Code size](https://img.shields.io/github/languages/code-size/qdm12/godevcontainer)
![GitHub repo size](https://img.shields.io/github/repo-size/qdm12/godevcontainer)

![Visitors count](https://visitor-badge.laobi.icu/badge?page_id=godevcontainer.readme)

## Features

- Compatible with `amd64`, `386`, `arm64`, `armv6` and `armv7` CPUs
- `ghcr.io/qdm12/godevcontainer:alpine` and `ghcr.io/qdm12/godevcontainer`
  - Based on Alpine 3.24 (size of 1.21GB)
- `ghcr.io/qdm12/godevcontainer:debian`
  - Based on Debian Trixie Slim (size of 1.37GB)
- Based on [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer)
  - Based on either Alpine or Debian
  - Minimal custom terminal and packages
  - See more [features](https://github.com/qdm12/basedevcontainer#features)
- Go 1.27 code obtained from the latest tagged Golang Docker image
- Go tooling [integrating with VS code](https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on), all cross built statically from source at the [binpot](https://github.com/qdm12/binpot):
  - [Google's Go language server gopls](https://github.com/golang/tools/tree/master/gopls)
  - [golangci-lint](https://github.com/golangci/golangci-lint), includes golint and other linters
  - [dlv](https://github.com/go-delve/delve/cmd/dlv) ⚠️ only works on `amd64` and `arm64`
  - [gomodifytags](https://github.com/fatih/gomodifytags)
  - [goplay](https://github.com/haya14busa/goplay)
  - [impl](https://github.com/josharian/impl)
  - [gotype-live](https://github.com/tylerb/gotype-live)
  - [gotests](https://github.com/cweill/gotests)
  - [gopkgs v2](https://github.com/uudashr/gopkgs/tree/master/v2)
- Terminal Go tools
  - [mockgen](https://github.com/uber-go/mock) to generate mocks
  - [mockery](https://github.com/vektra/mockery) to generate mocks for testify/mock
- Runs as an unprivileged user (`user`, uid/gid `1000` by default, configurable), see [Non-root user](#non-root-user)
  - `apk` (Alpine) and `apt-get` (Debian) install packages from that user, no sudo involved
- Cross platform
  - Easily bind mount your SSH keys to use with **git**
  - Manage your host Docker from within the dev container, more details at [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer#features)
- Compatible with both the Docker and Podman engines
- Extensible with docker-compose.yml
- Comes with extra Go binary tools for a few extra MBs: `kubectl`, `kubectx`, `kubens`, `stern` and `helm`

## Requirements

- [Docker](https://www.docker.com/products/docker-desktop) or [Podman](https://podman.io/getting-started/installation) installed and running
  - If you use OSX, share the `~/.ssh` directory and the directory of your project with Docker Desktop
- [VS code](https://code.visualstudio.com/download) installed
- [VS code dev containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

## Setup for a project

1. Setup your configuration files
    - With style 💯

        ```sh
        docker run -it --rm -v "/yourrepopath:/repository" qmcgaw/devtainr:v0.2.0 -dev go -path /repository -name projectname
        ```

        Or use the [built binary](https://github.com/qdm12/devtainr#binary)
    - Or manually: download this repository and put the [.devcontainer](.devcontainer) directory in your project. It holds a `docker/` and a `podman/` configuration, pick the one matching your container engine.
1. If you have a *.vscode/settings.json*, eventually move the settings to *`.devcontainer/*/devcontainer.json`* in the `"settings"` section as *.vscode/settings.json* take precedence over the settings defined in *.devcontainer/*/devcontainer.json*.
1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P) and select `Dev Containers: Open Folder in Container...` and choose your project directory

## Non-root user

The image runs using an unprivileged account `user`, created by the [base image](https://github.com/qdm12/basedevcontainer#non-root-user).

💁 In case you need root access, see [the root user section](#root-user)

The non root user is configurable with container build arguments, defined both in the Dockerfiles and in the devcontainer.json files:

| Build argument | Default | Description |
| --- | --- | --- |
| `USERNAME` | `user` | account name, home is `/home/$USERNAME`. Update the `"remoteUser"` key and mount targets in `devcontainer.json` to match this one if changed. |
| `GROUP_NAME` | `user` | name of the account's primary group |
| `USER_UID` | `1000` | user ID of the account |
| `USER_GID` | `1000` | group ID of the account's primary group (`$GROUP_NAME`) |
| `DOCKER_GID` | | create a `docker` group with this GID and put the account in it, to reach a rootful engine's socket, see [Container engine](.devcontainer/README.md#docker-engine) |

The unprivileged account:

- owns its home, `/go` (its `GOPATH`), and the state directories of the package manager, so it can install and remove packages without `sudo` or `doas`
- can write to a directory a package may add or remove a file in (`/usr/local/bin`, `/etc/ssl/certs`, `/var/log`...), which all belong to `$GROUP_NAME` and are group-writable.
- can only read and execute files installed in the container image and setup by the container engine
- cannot read `/root` and `/etc/shadow`

On system package management, note:

- it cannot replace a file the image already has installed, since those keep their root ownership
- for the Debian container, some packages have maintainer scripts that insist on running as root, and will fail to install (i.e. `dbus`); the fix is to finish the job as root for example `docker exec --user root <container-name> sh -c 'apt-get install -y dbus && dpkg --configure -a'`

## Root user

If you need to run a command as root, exec in the container using for example

```sh
docker exec --user root <container-name> command
```

Root has the same terminal setup as the unprivileged account, given its configuration files are symlinks into `/home/user`.
Note however that by default the zsh history and ssh files are not symlinked or copied from the unprivileged user to root.
The shell prints `Running as root` at startup, so you always know which account a terminal belongs to.

## Customization

See the [.devcontainer/README.md](.devcontainer/README.md) document in your repository.

When you extend the image in a Dockerfile, the build runs as the unprivileged account: use `USER root` before instructions that do need root, and `USER user` to give it back.

### docker-compose.yml

You can create a `.devcontainer/docker-compose.yml` to create the devcontainer and other containers at the same time:

```yml
services:
  vscode: # configured in devcontainer.json
    build: .
  postgres: # example of a database container
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: password
```

And change the following in your relevant `devcontainer.json`:

- remove `"build": { "dockerfile": "../Dockerfile" },`
- add `"dockerComposeFile": "../docker-compose.yml",`
- add `"overrideCommand": true,`
- add `"service": "vscode",`
- add `"runServices": ["vscode", "postgres"],`

Finally, open the command palette in Visual Studio Code (CTRL+SHIFT+P) and select `Dev-Containers: Rebuild Container`

## TODOs

- [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer) todos

## License

This repository is under an [MIT license](https://github.com/qdm12/godevcontainer/master/LICENSE) unless indicated otherwise.
