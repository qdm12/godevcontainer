# Go Dev Container

**Ultimate Go development container for Visual Studio Code**

[![godevcontainer](https://github.com/qdm12/godevcontainer/raw/master/title.png)](https://hub.docker.com/r/qmcgaw/godevcontainer)

[![Build Status](https://travis-ci.org/qdm12/godevcontainer.svg?branch=master)](https://travis-ci.org/qdm12/godevcontainer)
[![Docker Pulls](https://img.shields.io/docker/pulls/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Docker Stars](https://img.shields.io/docker/stars/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Image size](https://images.microbadger.com/badges/image/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)
[![Image version](https://images.microbadger.com/badges/version/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)

[![Join Slack channel](https://img.shields.io/badge/slack-@qdm12-yellow.svg?logo=slack)](https://join.slack.com/t/qdm12/shared_invite/enQtOTE0NjcxNTM1ODc5LTYyZmVlOTM3MGI4ZWU0YmJkMjUxNmQ4ODQ2OTAwYzMxMTlhY2Q1MWQyOWUyNjc2ODliNjFjMDUxNWNmNzk5MDk)
[![GitHub last commit](https://img.shields.io/github/last-commit/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub issues](https://img.shields.io/github/issues/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)

## Features

- Based on [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer):
    - Alpine 3.11 with minimal custom terminal and packages
    - Go 1.13.7 code obtained from the latest Golang Alpine Docker image
    - See more [features](https://github.com/qdm12/basedevcontainer#features)
- Using a patch to run `go test -race` on Alpine
- Go tooling [integrating with VS code](https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on):
    - [Google's Go language server gopls](https://github.com/golang/tools/tree/master/gopls)
    - [golangci-lint](https://github.com/golangci/golangci-lint)
    - [go-outline](https://github.com/ramya-rao-a/go-outline)
    - [go-symbols](https://github.com/acroca/go-symbols)
    - [gopkgs](https://github.com/uudashr/gopkgs)
    - [guru](https://golang.org/x/tools/cmd/guru)
    - [gorename](https://golang.org/x/tools/cmd/gorename)
    - [golint](https://golang.org/x/lint/golint)
    - [dlv](https://github.com/go-delve/delve/cmd/dlv)
    - [gomodifytags](https://github.com/fatih/gomodifytags)
    - [goplay](https://github.com/haya14busa/goplay)
    - [impl](https://github.com/josharian/impl)
    - [gotype-live](https://github.com/tylerb/gotype-live)
    - [gotests](https://github.com/cweill/gotests)
    - [fillstruct](https://github.com/davidrjenni/reftools/cmd/fillstruct)
- Terminal Go tools
    - [mockery](https://github.com/vektra/mockery) to generate mocks for testify/mock
- Cross platform
    - Easily bind mount your SSH keys to use with **git**
    - Manage your host Docker from within the dev container, more details at [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer#features)
- Extensible with docker-compose.yml
- ~Compatible with `arm/v8` and `arm/v7`~ because of the Alpine bug to run `go test -race`

## Requirements

- [Docker](https://www.docker.com/products/docker-desktop) installed and running
    - If you don't use Linux, share the directories `~/.ssh` and the directory of your project with Docker Desktop
- [Docker Compose](https://docs.docker.com/compose/install/) installed
- [VS code](https://code.visualstudio.com/download) installed
- [VS code remote containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

## Setup for a project

1. Download this repository and put the `.devcontainer` directory in your project.
   Alternatively, use this shell script from your project path

    ```sh
    # we assume you are in /yourpath/myproject
    mkdir .devcontainer
    cd .devcontainer
    wget -q https://raw.githubusercontent.com/qdm12/godevcontainer/master/.devcontainer/devcontainer.json
    wget -q https://raw.githubusercontent.com/qdm12/godevcontainer/master/.devcontainer/docker-compose.yml
    ```

1. If you have a *.vscode/settings.json*, eventually move the settings to *.devcontainer/devcontainer.json* in the `"settings"` section as *.vscode/settings.json* take precedence over the settings defined in *.devcontainer/devcontainer.json*.
1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P) and select `Remote-Containers: Open Folder in Container...` and choose your project directory

## More

### devcontainer.json

- You can change the `"postCreateCommand"` to be relevant to your situation. In example it could be `go mod download && gofmt ./...` to combine two commands
- You can change the extensions installed in the Docker image within the `"extensions"` array
- Other Go settings can be changed or added in the `"settings"` object.

### docker-compose.yml

- You can publish a port to access it from your host
- Add containers to be launched with your development container. In example, let's add a postgres database.
    1. Add this block to `.devcontainer/docker-compose.yml`

        ```yml
          database:
            image: postgres
            restart: always
            environment:
              POSTGRES_PASSWORD: password
        ```

    1. In `.devcontainer/devcontainer.json` change the line `"runServices": ["vscode"],` to `"runServices": ["vscode", "database"],`
    1. In the VS code command palette, rebuild the container

### Development image

- You can build the development image yourself:

    ```sh
    docker build -t qmcgaw/godevcontainer https://github.com/qdm12/godevcontainer.git
    ```

- You can extend the Docker image `qmcgaw/godevcontainer` with your own instructions.

    1. Create a file `.devcontainer/Dockerfile` with `FROM qmcgaw/godevcontainer`
    1. Append instructions to the Dockerfile created. For example:
        - Add more Go packages and add an alias

            ```Dockerfile
            FROM qmcgaw/godevcontainer
            RUN go get -v honnef.co/go/tools/...
            RUN echo "alias ls='ls -al'" >> ~/.zshrc
            ```

        - Add some Alpine packages, you will need to switch to `root`:

            ```Dockerfile
            FROM qmcgaw/godevcontainer
            USER root
            apk add curl
            USER vscode
            ```

    1. Modify `.devcontainer/docker-compose.yml` and add `build: .` in the vscode service.
    1. Open the VS code command palette and choose `Remote-Containers: Rebuild container`

- You can bind mount a shell script to `/home/vscode/.welcome.sh` to replace the [current welcome script](shell/.welcome.sh)

## TODOs

- [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer) todos
- Remove custom race fix, waiting for [this issue to be resolved](https://github.com/golang/go/issues/14481)

## License

This repository is under an [MIT license](https://github.com/qdm12/godevcontainer/master/LICENSE) unless indicated otherwise.
