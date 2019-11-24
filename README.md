# Go Dev Container

**This is the ultimate Go development container for Visual Studio Code**

[![godevcontainer](https://github.com/qdm12/godevcontainer/raw/master/title.png)](https://hub.docker.com/r/qmcgaw/godevcontainer)

[![Docker Build Status](https://img.shields.io/docker/cloud/build/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)

[![GitHub last commit](https://img.shields.io/github/last-commit/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)
[![GitHub issues](https://img.shields.io/github/issues/qdm12/godevcontainer.svg)](https://github.com/qdm12/godevcontainer/issues)

[![Docker Pulls](https://img.shields.io/docker/pulls/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Docker Stars](https://img.shields.io/docker/stars/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)
[![Docker Automated](https://img.shields.io/docker/cloud/automated/qmcgaw/godevcontainer.svg)](https://hub.docker.com/r/qmcgaw/godevcontainer)

[![Image size](https://images.microbadger.com/badges/image/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)
[![Image version](https://images.microbadger.com/badges/version/qmcgaw/godevcontainer.svg)](https://microbadger.com/images/qmcgaw/godevcontainer)

## Features

- Based on [Alpine 3.10 with the minimal packages](https://github.com/qdm12/godevcontainer/blob/master/doc/alpine.md) and a custom terminal
- Go 1.13 with [Go binary tools](https://github.com/qdm12/godevcontainer/blob/master/doc/go.md)
- Using a [fix for go test -race](https://github.com/qdm12/godevcontainer/blob/master/doc/race.md)
- Cross platform
    - Easily bind mount your SSH keys to use with **git**
    - Manage your host Docker from within the dev container, more details at [doc/docker.md](https://github.com/qdm12/godevcontainer/blob/master/doc/docker.md)
- Runs without root by default but you can `sudo`
- 'Minimal' size of **820MB**
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
    wget -q https://github.com/qdm12/godevcontainer/blob/master/.devcontainer/devcontainer.json
    wget -q https://github.com/qdm12/godevcontainer/blob/master/.devcontainer/docker-compose.yml
    ```

1. If you have a *.vscode/settings.json*, eventually move the settings to *.devcontainer/devcontainer.json* in the `"settings"` section as *.vscode/settings.json* take precedence over the settings defined in *.devcontainer/devcontainer.json*.
1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P) and select `Remote-Containers: Open Folder in Container...` and choose your project directory

## More

### devcontainer.json

- You can change the `"postCreateCommand"` to be relevant to your situation. In example it could be `go mod download && gofmt ./...` to combine two commands
- You can change the extensions installed in the Docker image within the `"extensions"` array
- Other Go settings can be changed or added in the `"settings"` object.
- You can publish a port to your localhost by uncommenting `// "appPort": 8000,` to access your app from a browser on your desktop for example.

### docker-compose.yml

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

You can build and extend the Docker development image to suit your needs, more information is available at [doc/image.md](https://github.com/qdm12/godevcontainer/blob/master/doc/image.md)

### welcome.sh

You can bind mount a shell script to `/home/vscode/.welcome.sh` to replace the [current welcome script](shell/welcome.sh) to suit your needs.

## License

This repository is under an [MIT license](https://github.com/qdm12/godevcontainer/master/LICENSE) unless indicated otherwise.
