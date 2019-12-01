# Extend

There are various methods to customize this image.

## Build the image

You can build the development image yourself:

```sh
docker build -t qmcgaw/godevcontainer https://github.com/qdm12/godevcontainer.git
```

Some build arguments are available with the `--build-arg` flag: `ALPINE_VERSION`, `GO_VERSION`, `DOCKER_VERSION`, `DOCKER_COMPOSE_VERSION`.
You can see defaults from the [Dockerfile](https://github.com/qdm12/godevcontainer/blob/master/Dockerfile).

## Extend the image

You can extend the Docker image `qmcgaw/godevcontainer` with your own instructions.

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

## Special files

You can bind mount a file at `/home/vscode/.welcome.sh` to modify the welcome message (use `/root/.welcome.sh` for `root`).
