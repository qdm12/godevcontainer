# Go Dev Container

**Ultimate Go development container for Visual Studio Code**

[![godevcontainer](https://github.com/qdm12/godevcontainer/raw/master/title.png)](https://hub.docker.com/r/qmcgaw/godevcontainer)

[![Build status](https://github.com/qdm12/godevcontainer/workflows/Buildx%20latest/badge.svg)](https://github.com/qdm12/godevcontainer/actions?query=workflow%3A%22Buildx+latest%22)
[![Docker Pulls](https://img.shields.io/docker/pulls/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Docker Stars](https://img.shields.io/docker/stars/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Image size](https://images.microbadger.com/badges/image/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)
[![Image version](https://images.microbadger.com/badges/version/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)

![Visitors count](https://visitor-badge.laobi.icu/badge?page_id=godevcontainer.readme)
[![Join Slack channel](https://img.shields.io/badge/slack-@qdm12-yellow.svg?logo=slack)](https://join.slack.com/t/qdm12/shared_invite/enQtOTE0NjcxNTM1ODc5LTYyZmVlOTM3MGI4ZWU0YmJkMjUxNmQ4ODQ2OTAwYzMxMTlhY2Q1MWQyOWUyNjc2ODliNjFjMDUxNWNmNzk5MDk)
[![GitHub last commit](https://img.shields.io/github/last-commit/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub issues](https://img.shields.io/github/issues/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)

## Video

[Video: what is it, how to set it up and how to customize it](https://youtu.be/t8KMhp4U40g)

## Features

- `qmcgaw/godevcontainer:alpine` and `qmcgaw/godevcontainer`
    - Based on Alpine 3.12 (size of 827MB)
- `qmcgaw/godevcontainer:debian` - **beware [it has CVE](https://github.com/qdm12/godevcontainer/runs/596825646?check_suite_focus=true) because of outdated packages**
    - Based on Debian Bullseye Slim (size of 891MB)
- Based on [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer)
    - Based on either Alpine 3.12 or Debian buster slim
    - Minimal custom terminal and packages
    - Go 1.15 code obtained from the latest Golang Docker image
    - See more [features](https://github.com/qdm12/basedevcontainer#features)
- Go tooling [integrating with VS code](https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on):
    - [Google's Go language server gopls](https://github.com/golang/tools/tree/master/gopls)
    - [golangci-lint](https://github.com/golangci/golangci-lint), includes golint and other linters
    - [guru](https://golang.org/x/tools/cmd/guru)
    - [gorename](https://golang.org/x/tools/cmd/gorename)
    - [dlv](https://github.com/go-delve/delve/cmd/dlv)
    - [gomodifytags](https://github.com/fatih/gomodifytags)
    - [goplay](https://github.com/haya14busa/goplay)
    - [impl](https://github.com/josharian/impl)
    - [gotype-live](https://github.com/tylerb/gotype-live)
    - [gotests](https://github.com/cweill/gotests)
    - [fillstruct](https://github.com/davidrjenni/reftools/cmd/fillstruct)
- Terminal Go tools
    - [mockgen](https://github.com/golang/mock/mockgen) to generate mocks
    - [mockery](https://github.com/vektra/mockery) to generate mocks for testify/mock
- Cross platform
    - Easily bind mount your SSH keys to use with **git**
    - Manage your host Docker from within the dev container, more details at [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer#features)
- Extensible with docker-compose.yml
- Comes with extra Go binary tools for a few extra MBs: `kubectl`, `kubectx`, `kubens`, `stern` and `helm`

## Requirements

- [Docker](https://www.docker.com/products/docker-desktop) installed and running
    - If you don't use Linux, share the directories `~/.ssh` and the directory of your project with Docker Desktop
- [Docker Compose](https://docs.docker.com/compose/install/) installed
- [VS code](https://code.visualstudio.com/download) installed
- [VS code remote containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

## Setup for a project

1. Download this repository and put the [.devcontainer](.devcontainer) directory in your project.
1. If you have a *.vscode/settings.json*, eventually move the settings to *.devcontainer/devcontainer.json* in the `"settings"` section as *.vscode/settings.json* take precedence over the settings defined in *.devcontainer/devcontainer.json*.
1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P) and select `Remote-Containers: Open Folder in Container...` and choose your project directory

## Customization

See the [.devcontainer/README.md](.devcontainer/README.md) document in your repository.

## TODOs

- [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer) todos
- Setup Go binary

## License

This repository is under an [MIT license](https://github.com/qdm12/godevcontainer/master/LICENSE) unless indicated otherwise.
