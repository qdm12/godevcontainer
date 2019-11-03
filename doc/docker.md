# Docker

The Docker CLI and Docker-Compose are installed as binaries in the Docker image.
They allow you to interact with your Docker engine of your host, by mapping `/var/run/docker.sock` in your dev container.

## Source

- Docker CLI is copied from the [docker:19.03.4](https://hub.docker.com/_/docker) image to `/usr/local/bin/docker`
- Docker-Compose CLI is copied from the [docker/compose:1.25.0-rc4-alpine](https://hub.docker.com/r/docker/compose/tags) image to `/usr/local/bin/docker-compose`

## Build Kit

Build Kit is enabled by default to build Docker images in a faster, prettier way with `DOCKER_BUILDKIT=1`

## Run without sudo

The default user can interact with your host Docker socket on Linux, OSX and Windows:

- On **Linux**, the `docker.sock` is owned by as docker group usually with ID `987` or `102` or `1000` so the default user `vscode` is part of these group IDs.
- On **OSX** and **Windows**, the `docker.sock` is owned by the `root` group so the only way for now is to `sudo chown` the `docker.sock` file with the `vscode` group when you log in the shell terminal.

## Aliases

Some alias are set up to run terminal commands as interactive Docker sibling containers

- `dive <image_name>` to analyze a Docker image layers
- `ld` to run lazydocker
