ARG GO_VERSION=1.13
ARG ALPINE_VERSION=3.10

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION}
ARG BUILD_DATE
ARG VCS_REF
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
LABEL \
    org.opencontainers.image.authors="quentin.mcgaw@gmail.com" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.version="" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.url="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.documentation="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.source="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.title="Go Dev container" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Remote Containers development" \
    image-size="613MB"

# Setup user
RUN adduser $USERNAME -s /bin/sh -D -u $USER_UID $USER_GID && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Install Alpine packages
RUN apk add -q --update --progress --no-cache git sudo openssh-client zsh build-base nano
# Install development packages
RUN GO111MODULE=on go get -v \
    golang.org/x/tools/gopls@latest \
    github.com/ramya-rao-a/go-outline \
    github.com/go-delve/delve/cmd/dlv \
    2>&1
# Setup shell
USER $USERNAME
ENV ENV="/home/$USERNAME/.ashrc" \
    ZSH=/home/$USERNAME/.oh-my-zsh \
    ZSH_CUSTOM=/home/$USERNAME/.oh-my-zsh/custom \
    EDITOR=vi \
    LANG=en_US.UTF-8
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended &> /dev/null
RUN git clone --single-branch --depth 1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k &> /dev/null
COPY --chown=${USERNAME}:${USER_GID} .p10k.zsh /home/${USERNAME}/.p10k.zsh
RUN printf 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true\nZSH_THEME="powerlevel10k/powerlevel10k"\nENABLE_CORRECTION="false"\nplugins=(git copyfile extract colorize dotenv encode64 golang)\nsource $ZSH/oh-my-zsh.sh\nsource ~/.p10k.zsh' > "/home/$USERNAME/.zshrc" && \
    echo "exec `which zsh`" > "/home/$USERNAME/.ashrc"
USER root
