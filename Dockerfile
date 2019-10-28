ARG ALPINE_VERSION=3.10
ARG GO_VERSION=1.13
ARG DOCKER_VERSION=19.03.4
ARG DOCKER_COMPOSE_VERSION=1.25.0-rc2-alpine

FROM docker:${DOCKER_VERSION} AS docker-cli
FROM docker/compose:${DOCKER_COMPOSE_VERSION} AS docker-compose

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
    image-size="811MB"
WORKDIR /home/${USERNAME}
ENTRYPOINT [ "/bin/zsh" ]
CMD [ "" ]

# Setup user
RUN adduser $USERNAME -s /bin/sh -D -u $USER_UID $USER_GID && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Install Alpine packages
RUN apk add -q --update --progress ca-certificates sudo zsh bash nano git openssh-client libstdc++
COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker-compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose
RUN chown ${USERNAME}:${USER_GID} /usr/local/bin/docker /usr/local/bin/docker-compose && \
    chmod 500 /usr/local/bin/docker /usr/local/bin/docker-compose

# Setup shells
ENV EDITOR=nano \
    LANG=en_US.UTF-8
RUN apk add shadow && \
    usermod --shell /bin/zsh root && \
    usermod --shell /bin/zsh ${USERNAME} && \
    apk del shadow
COPY .p10k.zsh .zshrc /home/${USERNAME}/
RUN chown ${USERNAME}:${USER_GID} /home/${USERNAME}/.p10k.zsh /home/${USERNAME}/.zshrc && \
    ln -s /home/${USERNAME}/.p10k.zsh /root/.p10k.zsh && \
    cp /home/${USERNAME}/.zshrc /root/.zshrc && \
    sed -i "s/HOMEPATH/home\/${USERNAME}/" /home/${USERNAME}/.zshrc && \
    sed -i "s/HOMEPATH/root/" /root/.zshrc
RUN git clone --single-branch --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /home/${USERNAME}/.oh-my-zsh &> /dev/null && \
    rm -rf /home/${USERNAME}/.oh-my-zsh/.git
RUN git clone --single-branch --depth 1 https://github.com/romkatv/powerlevel10k.git /home/${USERNAME}/.oh-my-zsh/custom/themes/powerlevel10k &> /dev/null && \
    rm -rf /home/${USERNAME}/.oh-my-zsh/custom/themes/powerlevel10k/.git
RUN chown -R ${USERNAME}:${USER_GID} /home/${USERNAME}/.oh-my-zsh && \
    chmod -R 700 /home/${USERNAME}/.oh-my-zsh && \
    cp -r /home/${USERNAME}/.oh-my-zsh /root/.oh-my-zsh && \
    chown -R root:root /root/.oh-my-zsh

# Install development packages
RUN GO111MODULE=on go get -v \
    golang.org/x/tools/gopls@latest \
    github.com/ramya-rao-a/go-outline \
    github.com/go-delve/delve/cmd/dlv \
    github.com/mdempsky/gocode \
    github.com/uudashr/gopkgs/cmd/gopkgs \
    github.com/stamblerre/gocode \
    github.com/rogpeppe/godef \
    2>&1 && \
    chown -R ${USERNAME}:${USER_GID} /go

USER ${USERNAME}
