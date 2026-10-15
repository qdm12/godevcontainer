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
    touch ~/AGENTS.md # AI agent context file
    ```

    On top of these files, note by default this container bind mounts:

    - Some public files from `~/.ssh` (no private key), see the [SSH agent section below](#ssh-agent)
    - The Docker daemon socket `/var/run/docker.sock`

    You can alternatively modify the mounts in [devcontainer.json](devcontainer.json) to suit your needs.
1. **For OSX hosts**: ensure the project directory and your home directory `~` are accessible by Docker.
1. Whether you want to use SSH or not, see the [SSH keys section below](#ssh-keys)
1. Open the command palette in Visual Studio Code (CTRL+SHIFT+P).
1. Select `Dev-Containers: Open Folder in Container...` and choose the project directory.

### SSH keys

Three options as subsections below: ssh agent, ssh bind mount, or no ssh.

#### SSH agent

This is the default, preferred and more secure method.
You need to have the agent running on your host and have the environment variable `SSH_AUTH_SOCK` set to the path to the agent socket.

Just make sure you have the `~/.ssh/known_hosts` file on your host.

For example, if your SSH private key is `~/.ssh/id_ed25519` you can have a systemd unit `~/.config/systemd/user/ssh-agent.service` like this:

```ini
[Unit]
Description=OpenSSH key agent
Documentation=man:ssh-agent(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.sock
ExecStart=/usr/bin/ssh-agent -D -a %t/ssh-agent.sock
# Leading - so a missing/unreadable key never fails the unit.
# Loops because the socket is created shortly after ssh-agent starts.
ExecStartPost=-/bin/sh -c 'for i in $(seq 1 50); do ssh-add %h/.ssh/id_ed25519 2>/dev/null && exit 0; sleep 0.1; done; exit 1'
Restart=on-failure
RestartSec=1s
UMask=0077

[Install]
WantedBy=default.target
```

💁 this also works on WSL2 with Ubuntu

By default, the devcontainer mounts files to be able to use GPG SSH git commit signing with an `id_ed25519`-named key:

- `~/.ssh/allowed_signers` <-> `/root/.ssh/allowed_signers`
- `~/.ssh/id_ed25519.pub` <-> `/root/.ssh/id_ed25519.pub` - `id_ed25519.pub` may need to be adapted to match your key filename

If you do not want to use GPG SSH git commit signing, comment out the mounts in `devcontainer.json`:

```jsonc
{
    "source": "${localEnv:HOME}/.ssh/id_ed25519.pub",
    "target": "/root/.ssh/id_ed25519.pub",
    "type": "bind,readonly"
},
{
    "source": "${localEnv:HOME}/.ssh/allowed_signers",
    "target": "/root/.ssh/allowed_signers",
    "type": "bind,readonly"
},
```

#### SSH bind mount

You bind mount `~/.ssh` to `/mnt/ssh` in the container, and the [ssh script](https://github.com/qdm12/basedevcontainer/blob/master/.ssh.sh) takes care of mapping those to `~/.ssh` in the container depending on the host platform.

This is **not the default** so `devcontainer.json` needs the following changes:

1. Comment out with `//`

    ```jsonc
    "SSH_AUTH_SOCK": "/tmp/ssh-agent.sock"
    ```

    ```jsonc
    {
        "source": "${localEnv:SSH_AUTH_SOCK}",
        "target": "/tmp/ssh-agent.sock",
        "type": "bind"
    },
    {
        "source": "${localEnv:HOME}/.ssh/id_ed25519.pub",
        "target": "/root/.ssh/id_ed25519.pub",
        "type": "bind,readonly"
    },
    {
        "source": "${localEnv:HOME}/.ssh/allowed_signers",
        "target": "/root/.ssh/allowed_signers",
        "type": "bind,readonly"
    },
    ```

1. Uncomment by removing `//`:

    ```jsonc
    // {
    //     "source": "${localEnv:HOME}/.ssh",
    //     "target": "/mnt/ssh",
    //     "type": "bind"
    // },
    ```

#### No SSH

If you do not want to use SSH at all, comment out

```jsonc
"SSH_AUTH_SOCK": "/tmp/ssh-agent.sock"
```

and all the ssh mounts in `devcontainer.json`:

```jsonc
{
    "source": "${localEnv:SSH_AUTH_SOCK}",
    "target": "/tmp/ssh-agent.sock",
    "type": "bind"
},
{
    "source": "${localEnv:HOME}/.ssh/known_hosts",
    "target": "/etc/ssh/ssh_known_hosts",
    "type": "bind"
},
{
    "source": "${localEnv:HOME}/.ssh/id_ed25519.pub",
    "target": "/root/.ssh/id_ed25519.pub",
    "type": "bind,readonly"
},
{
    "source": "${localEnv:HOME}/.ssh/allowed_signers",
    "target": "/root/.ssh/allowed_signers",
    "type": "bind,readonly"
},
```

## Github cli `gh`

1. [Create fine grained personal access token](https://github.com/settings/personal-access-tokens)
2. Set it on your host environment variable as `GH_TOKEN`:

    ```sh
    export GH_TOKEN=ghp_XXXXXXXXXXXXXXXX
    ```

3. The devcontainer will pick it up and inject it as `GH_TOKEN`, which is then used by `gh` within the devcontainer.

If needed, you can modify this in the [devcontainer.json](devcontainer.json) file `containerEnv` key, for example if you prefer to read another variable name.

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
