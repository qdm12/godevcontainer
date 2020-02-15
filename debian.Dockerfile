FROM qmcgaw/basedevcontainer:debian
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
    org.opencontainers.image.title="Go Dev container Debian" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Remote Containers development"
USER root
COPY --from=golang:1.13.7-buster /usr/local/go /usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    CGO_ENABLED=0 \
    GO111MODULE=on
WORKDIR $GOPATH
# Install Alpine packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends g++ && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -r /var/cache/* /var/lib/apt/lists/*
# Shell setup
COPY --chown=${USER_UID}:${USER_GID} shell/.zshrc-specific shell/.welcome.sh /home/${USERNAME}/
COPY shell/.zshrc-specific shell/.welcome.sh /root/
# Install Go packages
ARG GOLANGCI_LINT_VERSION=v1.23.6
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin -d ${GOLANGCI_LINT_VERSION}
RUN CPUARCH="$(dpkg --print-architecture)" && \
    if [ "$CPUARCH" = "amd64" ]; then \
    go get -v github.com/go-delve/delve/cmd/dlv && \
    chown ${USERNAME}:${USER_GID} /go/bin/* && \
    chmod 500 /go/bin/* && \
    rm -rf /go/pkg /go/src/* /root/.cache/go-build; fi
RUN go get -v \
    # Base Go tools needed for VS code Go extension
    golang.org/x/tools/gopls \
    github.com/ramya-rao-a/go-outline \
    github.com/acroca/go-symbols \
    github.com/uudashr/gopkgs/cmd/gopkgs@latest \
    golang.org/x/tools/cmd/guru \
    golang.org/x/tools/cmd/gorename \
    golang.org/x/lint/golint \
    # Extra tools integrating with VS code
    github.com/fatih/gomodifytags \
    github.com/haya14busa/goplay/cmd/goplay \
    github.com/josharian/impl \
    github.com/tylerb/gotype-live \
    github.com/cweill/gotests/... \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    # Terminal tools
    github.com/golang/mock/mockgen \
    github.com/vektra/mockery/... \
    2>&1 && \
    rm -rf /go/pkg/* /go/src/* /root/.cache/go-build && \
    chown ${USERNAME}:${USER_GID} /go && \
    chmod 777 /go
USER ${USERNAME}
