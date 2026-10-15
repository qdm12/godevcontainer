# Development container

Development container that can be used with VSCode.

It works on Linux, Windows (WSL2) and OSX.

## Requirements

- [VS code](https://code.visualstudio.com/download) installed
- [VS code dev containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed
- [Docker](https://www.docker.com/products/docker-desktop) installed and running

## Setup

1. This dev container expects to bind mount several files directly, so they must exist on the host, even if empty:

    ```sh
    touch ~/.gitconfig # git configuration
    touch ~/.zsh_history # ZSH shell commands history
    ```

    On top of these files, note by default this container bind mounts the host `~/.ssh` directory and `/var/run/docker.sock`.

    You can alternatively modify the mounts in [devcontainer.json](devcontainer.json) to suit your needs.
1. **For OSX hosts**: ensure the project directory and your home directory `~` are accessible by Docker.
1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P).
1. Select `Dev-Containers: Open Folder in Container...` and choose the project directory.

## Customization

For customizations to take effect, you should "rebuild and reopen":

1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P)
2. Select `Dev-Containers: Rebuild Container`

Customizations available are notably:

- Changes to the Docker image in [Dockerfile](Dockerfile)
- Changes to VSCode **settings** and **extensions** in [devcontainer.json](devcontainer.json).
- Change the entrypoint script by adding a bind mount in [devcontainer.json](devcontainer.json) of a shell script to `/root/.welcome.sh` to replace the [current welcome script](https://github.com/qdm12/godevcontainer/blob/master/shell/.welcome.sh). For example:

    ```json
    // Welcome script
    {
        "source": "/yourpath/.welcome.sh",
        "target": "/root/.welcome.sh",
        "type": "bind"
    },
    ```

- Change the container configuration in [devcontainer.json](devcontainer.json)
- Add other services in a `docker-compose.yml`, see [this README section](https://github.com/qdm12/godevcontainer/blob/master/README.md#docker-composeyml)
- More customizations available are documented in the [devcontainer.json reference](https://containers.dev/implementors/json_reference/).

## Container engine

This container does not run an engine of its own: it mounts the **host's** container engine API socket, so `docker` and `docker compose` drive the host engine (run, build, cross-architecture build) and share its images etc.
Nothing needs to be installed beyond the client CLIs already in the image, and there are no privileges involved.

To ease using the host engine, because volume paths resolve on the host, the checkout is mounted at the same absolute path inside and outside the container (`workspaceFolder`), so `docker run -v $PWD/data:/data` refers to the same files on both sides. Note this is still limited to the bind mounted volumes, mounting a container path that the host does not have will fail.
