# Go Dev Container

**Ultimate Go development container for Visual Studio Code**

[![godevcontainer](https://github.com/qdm12/godevcontainer/raw/master/title.png)](https://hub.docker.com/r/qmcgaw/godevcontainer)

[![Build status](https://github.com/qdm12/godevcontainer/workflows/Buildx%20latest/badge.svg)](https://github.com/qdm12/godevcontainer/actions?query=workflow%3A%22Buildx+latest%22)
[![Docker Pulls](https://img.shields.io/docker/pulls/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Docker Stars](https://img.shields.io/docker/stars/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Image size](https://images.microbadger.com/badges/image/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)
[![Image version](https://images.microbadger.com/badges/version/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)

[![Join Slack channel](https://img.shields.io/badge/slack-@qdm12-yellow.svg?logo=slack)](https://join.slack.com/t/qdm12/shared_invite/enQtOTE0NjcxNTM1ODc5LTYyZmVlOTM3MGI4ZWU0YmJkMjUxNmQ4ODQ2OTAwYzMxMTlhY2Q1MWQyOWUyNjc2ODliNjFjMDUxNWNmNzk5MDk)
[![GitHub last commit](https://img.shields.io/github/last-commit/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub issues](https://img.shields.io/github/issues/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)

## Features

- `qmcgaw/godevcontainer:alpine` and `qmcgaw/godevcontainer` specifics
    - Based on Alpine 3.11 (size of 815MB)
    - Using a patch to run `go test -race` on Alpine
    - Only compatible with `amd64` because of the Alpine patch to run `go test -race`
- `qmcgaw/godevcontainer:debian`
    - Based on Debian Buster Slim (size of 881MB)
    - Compatible with `amd64` and `arm64` (ARM version misses [dlv](https://github.com/go-delve/delve/cmd/dlv))
- Based on [qmcgaw/basedevcontainer](https://github.com/qdm12/basedevcontainer)
    - Based on either Alpine 3.11 or Debian buster slim
    - Minimal custom terminal and packages
    - Go 1.14 code obtained from the latest Golang Docker image
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
    docker build -t qmcgaw/godevcontainer -f alpine.Dockerfile https://github.com/qdm12/godevcontainer.git
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
- Use build args to copy Go source code and binaries
- Remove custom race fix, waiting for [this issue to be resolved](https://github.com/golang/go/issues/14481) and add ARM compatibility

## License

This repository is under an [MIT license](https://github.com/qdm12/godevcontainer/master/LICENSE) unless indicated otherwise.
