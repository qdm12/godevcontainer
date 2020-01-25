ZSH=/HOMEPATH/.oh-my-zsh
ZSH_CUSTOM=$ZSH/custom
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
plugins=(vscode git colorize golang docker docker-compose)
source $ZSH/oh-my-zsh.sh
source ~/.p10k.zsh
# TODO Ascii art

# SSH key check
test -f ~/.ssh/id_rsa
[ "$?" = 0 ] && SSHRSA_OK=yes
[ -z $SSHRSA_OK ] && >&2 echo "[WARNING] No id_rsa SSH private key found, SSH functionalities might not work"

# Docker check
test -S /var/run/docker.sock
[ "$?" = 0 ] && DOCKERSOCK_OK=yes
[ -z $DOCKERSOCK_OK ] && >&2 echo "[WARNING] Docker socket not found, docker will not be available"

# Fixing permission on Docker socket
if [ ! -z $DOCKERSOCK_OK ]; then
  DOCKERSOCK_USER=`stat -c "%u" /var/run/docker.sock`
  DOCKERSOCK_GROUP=`stat -c "%g" /var/run/docker.sock`
  if [ "$DOCKERSOCK_GROUP" != "1000" ] && [ "$DOCKERSOCK_GROUP" != "102" ] && [ "$DOCKERSOCK_GROUP" != "976" ]; then
    echo "Docker socket not owned by group IDs 1000, 102 or 976, changing its group to `id -g`"
    sudo chown $DOCKERSOCK_USER:`id -g` /var/run/docker.sock
  fi
fi

echo
echo "Running as user `whoami`"
echo "Go version `go version | cut -d' ' -f3`"
if [ ! -z $DOCKERSOCK_OK ]; then
  echo "Docker server `docker version --format {{.Server.Version}}` | client `docker version --format {{.Client.Version}}`"
  echo "Docker-Compose `docker-compose version --short`"
  alias alpine='docker run -it --rm alpine:3.11'
  alias dive='docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive'
fi
echo
[ -z $TZ ] && echo "TZ environment variable not set, time might be wrong!"
[ -f ~/.welcome.sh ] && source ~/.welcome.sh
