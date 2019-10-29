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

What's bundled in this image?

- Go, Google's language server and development tools
- Manage your host Docker from within VS code in this container
- Bind mount your SSH keys to use ssh in VS code
- Use Git using VS code interface or terminal
- Custom terminal for user `vscode` and `root`
    - Zsh with [oh-my-zsh](https://ohmyz.sh/)
    - [Powerlevel10k theme](https://github.com/romkatv/powerlevel10k)
    - Oh-My-Zsh plugins: git, extract, colorize, encode64, golang

Extra goodies...

- Runs without root
- Minimal size of **811MB**
- Extensible with docker-compose.yml
- Compatible with ARM and other architectures
- Docker CLI and Docker-compose are statically built from source

## Requirements

- [Docker](https://www.docker.com/products/docker-desktop) installed and running with the following directories shared (if you don't use Linux):
    - `~/.ssh`
    - the directory of your project
- [Docker Compose](https://docs.docker.com/compose/install/) installed
- [VS code](https://code.visualstudio.com/download) installed
- [VS code remote containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

## Setup for a project

1. Download this repository and put the `.devcontainer` directory in your project.
   Alternatively, use this shell script from your project path

    ```sh
    # we assume you are in myproject
    mkdir .devcontainer
    wget -q https://github.com/qdm12/godevcontainer/blob/master/.devcontainer/devcontainer.json
    wget -q https://github.com/qdm12/godevcontainer/blob/master/.devcontainer/docker-compose.yml
    ```

1. If you have a *.vscode/settings.json*, eventually move the settings to *.devcontainer/devcontainer.json* in the `"settings"` section and remove *.vscode/settings.json*, as these won't be overwritten by the settings defined in *.devcontainer/devcontainer.json*.
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

- Build the development container yourself using

    ```sh
    docker build -t qmcgaw/godevcontainer https://github.com/qdm12/godevcontainer.git
    ```

    You can also pass the following `--build-arg` to the build command: `ALPINE_VERSION`, `GO_VERSION`, `DOCKER_VERSION`, `DOCKER_COMPOSE_VERSION`. You can see defaults from the [Dockerfile](https://github.com/qdm12/godevcontainer/blob/master/Dockerfile)

- Extend the current Docker image
    1. Create a file `.devcontainer/Dockerfile` with `FROM qmcgaw/godevcontainer`
    1. Append instructions to the Dockerfile created. You might want to use `USER root` to install packages and then switch back to `USER vscode` at the end. For example:

        ```Dockerfile
        FROM qmcgaw/godevcontainer
        # Running as vscode by default
        go get github.com/julienschmidt/httprouter
        USER root
        apk add curl
        USER vscode
        ```

    1. Modify `.devcontainer/docker-compose.yml` and add `build: .` in the vscode service.
    1. Open the VS code command palette and choose `Remote-Containers: Rebuilt container`

## TODOs

- [ ] Use less packages than `build-base`
- [ ] Install VS code extensions
    - [ ] In Docker image
    - [ ] In a named volume
- [ ] Readme
    - [ ] Extend another docker-compose.yml
- [ ] Automatically write Github RSA host key to known_hosts for root and vscode
- [ ] Install VS code server in Docker image
- [ ] Figure out Docker group IDs to be crossplatform
    - [x] OSX does not have `docker` group and needs `sudo docker` to run
        - Run docker with `sudo docker`
        - Alias `alias docker='sudo docker'`
        - Login as root with `sudo -E su`
    - [ ] Linux has Docker group, find which ID
    - [ ] Windows?

## License

This repository is under an [MIT license](https://github.com/qdm12/godevcontainer/master/LICENSE)
