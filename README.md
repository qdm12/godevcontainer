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
- `qmcgaw/godevcontainer:alpine` and `qmcgaw/godevcontainer`
  - Based on Alpine 3.19 (size of 936MB)
- `qmcgaw/godevcontainer:debian` - **beware [it has CVE](https://github.com/qdm12/godevcontainer/runs/596825646?check_suite_focus=true) because of outdated packages**
  - Based on Debian Buster Slim (size of 1.24GB)
- Based on [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer)
  - Based on either Alpine or Debian
  - Minimal custom terminal and packages
  - See more [features](https://github.com/qdm12/basedevcontainer#features)
- Go 1.22 code obtained from the latest tagged Golang Docker image
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
  - [mockgen](https://github.com/golang/mock) to generate mocks
  - [mockery](https://github.com/vektra/mockery) to generate mocks for testify/mock
- Cross platform
  - Easily bind mount your SSH keys to use with **git**
  - Manage your host Docker from within the dev container, more details at [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer#features)
- Extensible with docker-compose.yml
- Comes with extra Go binary tools for a few extra MBs: `kubectl`, `kubectx`, `kubens`, `stern` and `helm`

## Requirements

- [Docker](https://www.docker.com/products/docker-desktop) installed and running
  - If you don't use Linux or Windows with WSL, share the directory `~/.ssh` and the directory of your project with Docker Desktop
- [Docker Compose](https://docs.docker.com/compose/install/) installed
- [VS code](https://code.visualstudio.com/download) installed
- [VS code remote containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

## Setup for a project

1. Setup your configuration files
    - With style 💯

        ```sh
        docker run -it --rm -v "/yourrepopath:/repository" qmcgaw/devtainr:v0.2.0 -dev go -path /repository -name projectname
        ```

        Or use the [built binary](https://github.com/qdm12/devtainr#binary)
    - Or manually: download this repository and put the [.devcontainer](.devcontainer) directory in your project.
1. If you have a *.vscode/settings.json*, eventually move the settings to *.devcontainer/devcontainer.json* in the `"settings"` section as *.vscode/settings.json* take precedence over the settings defined in *.devcontainer/devcontainer.json*.
1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P) and select `Remote-Containers: Open Folder in Container...` and choose your project directory

## Customization

See the [.devcontainer/README.md](.devcontainer/README.md) document in your repository.

## TODOs

- [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer) todos

## License

This repository is under an [MIT license](https://github.com/qdm12/godevcontainer/master/LICENSE) unless indicated otherwise.
