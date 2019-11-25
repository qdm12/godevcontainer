ARG ALPINE_VERSION=3.10
ARG GO_VERSION=1.13
ARG DOCKER_VERSION=19.03.4
ARG DOCKER_COMPOSE_VERSION=1.25.0-rc4-alpine

FROM docker:${DOCKER_VERSION} AS docker-cli
FROM docker/compose:${DOCKER_COMPOSE_VERSION} AS docker-compose

# See https://github.com/golang/go/issues/14481
FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS race
WORKDIR /tmp/race
RUN apk --update -q --progress --no-cache add git g++
RUN git clone --single-branch https://llvm.org/git/compiler-rt.git . &> /dev/null
RUN git reset --hard fe2c72c59aa7f4afa45e3f65a5d16a374b6cce26 && \
    wget -q https://github.com/golang/go/files/3615484/0001-hack-to-make-Go-s-race-flag-work-on-Alpine.patch.gz -O patch.gz && \
    gunzip patch.gz && \
    patch -p1 -i patch
RUN cd lib/tsan/go && \
    ./buildgo.sh &> /dev/null

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION}
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=local
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
LABEL \
    org.opencontainers.image.authors="quentin.mcgaw@gmail.com" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.url="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.documentation="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.source="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.title="Go Dev container" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Remote Containers development"
WORKDIR /home/${USERNAME}
ENTRYPOINT [ "/bin/zsh" ]

# Patch for go test -race on Alpine
COPY --from=race /tmp/race/lib/tsan/go/race_linux_amd64.syso /usr/local/go/src/runtime/race/race_linux_amd64.syso

# Setup user
RUN adduser $USERNAME -s /bin/sh -D -u $USER_UID $USER_GID && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Ownership of Go empty directories
RUN chown ${USERNAME}:${USER_GID} /go/bin /go/src

# Install Alpine packages
RUN apk add -q --update --progress libstdc++ g++ zsh sudo ca-certificates git openssh-client bash nano

# Setup Docker TODO: replace `COPY --chown=vscode` with `COPY --chown=${USER_UID}:${USER_GID}`
COPY --from=docker-cli --chown=vscode /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker-compose --chown=vscode /usr/local/bin/docker-compose /usr/local/bin/docker-compose
ENV DOCKER_BUILDKIT=1
# All possible docker host groups
RUN ([ ${USER_GID} = 1000 ] || (addgroup -g 1000 docker1000 && addgroup ${USERNAME} docker1000)) && \
    addgroup -g 976 docker976 && \
    addgroup -g 102 docker102 && \
    addgroup ${USERNAME} docker976 && \
    addgroup ${USERNAME} docker102

# Setup shells
ENV EDITOR=nano \
    LANG=en_US.UTF-8
RUN apk add shadow && \
    usermod --shell /bin/zsh root && \
    usermod --shell /bin/zsh ${USERNAME} && \
    apk del shadow
COPY --chown=vscode shell/.p10k.zsh shell/.zshrc shell/.welcome.sh /home/${USERNAME}/
RUN ln -s /home/${USERNAME}/.p10k.zsh /root/.p10k.zsh && \
    cp /home/${USERNAME}/.zshrc /root/.zshrc && \
    cp /home/${USERNAME}/.welcome.sh /root/.welcome.sh && \
    sed -i "s/HOMEPATH/home\/${USERNAME}/" /home/${USERNAME}/.zshrc && \
    sed -i "s/HOMEPATH/root/" /root/.zshrc
RUN git clone --single-branch --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /home/${USERNAME}/.oh-my-zsh &> /dev/null && \
    rm -rf /home/${USERNAME}/.oh-my-zsh/.git && \
    git clone --single-branch --depth 1 https://github.com/romkatv/powerlevel10k.git /home/${USERNAME}/.oh-my-zsh/custom/themes/powerlevel10k &> /dev/null && \
    rm -rf /home/${USERNAME}/.oh-my-zsh/custom/themes/powerlevel10k/.git && \
    chown -R ${USERNAME}:${USER_GID} /home/${USERNAME}/.oh-my-zsh && \
    chmod -R 700 /home/${USERNAME}/.oh-my-zsh && \
    cp -r /home/${USERNAME}/.oh-my-zsh /root/.oh-my-zsh && \
    chown -R root:root /root/.oh-my-zsh

# Install Go packages
ENV GO111MODULE=on
RUN go get -v \
    # Base Go tools needed for VS code Go extension
    golang.org/x/tools/gopls@v0.2.0 \
    github.com/ramya-rao-a/go-outline \
    github.com/acroca/go-symbols \
    github.com/uudashr/gopkgs/cmd/gopkgs@latest \
    golang.org/x/tools/cmd/guru \
    golang.org/x/tools/cmd/gorename \
    golang.org/x/lint/golint \
    github.com/go-delve/delve/cmd/dlv \
    # Extra tools integrating with VS code
    github.com/fatih/gomodifytags \
    github.com/haya14busa/goplay/cmd/goplay \
    github.com/josharian/impl \
    github.com/tylerb/gotype-live \
    github.com/cweill/gotests/... \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    # Terminal tools
    github.com/vektra/mockery/... \
    github.com/kyoh86/scopelint \
    2>&1 && \
    chown ${USERNAME}:${USER_GID} /go/bin/* && \
    chmod 500 /go/bin/* && \
    rm -rf /go/pkg /go/src/* /root/.cache/go-build

USER ${USERNAME}
