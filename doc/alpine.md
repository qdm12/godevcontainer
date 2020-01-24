# Alpine

Alpine 3.11 was the chosen base OS as it is very lightweight and easy to use.

## Packages

The image comes with several Alpine packages installed.

- `libstdc++` is needed by the VS code server
- `g++` is needed by Go if `CGO_ENABLED=1` which is needed to run `go test` with the `-race` flag
- `zsh` as the main shell instead of `/bin/sh`
- `sudo` to run commands as root if needed
- `ca-certificates` to get the lastest certificates for HTTPs
- `git` to interact with Git repositories
- `openssh-client` to use SSH keys with Git
- `bash` for shell scripts written for bash
- `nano` to edit files simply

## User

A user, by default `vscode`, is created in the Docker image.
The Docker image will run with this user instead of `root` by default.
The user `vscode` belongs to the groups with ID `1000`, `976` and `102` (see why in [docker.md](docker.md)).
It is added to the list of sudoers so that you can run commands with `sudo` if needed.

Both `vscode` and `root` users have their default shell set as the terminal described below with the same [profile file](../.zshrc).

## Terminal

The terminal is quite customized, it is based on:

- `zsh`
- The [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) framework with the plugins `vscode`, `git`, `colorize`, `golang`, `docker` and `docker-compose`.
- The theme [Powerlevel10k](https://github.com/romkatv/powerlevel10k) with some [default settings](../.p10k.zsh).

It also shows some information on login, such as the Go version or if the docker socket is accessible for example.
