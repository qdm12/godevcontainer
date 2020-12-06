ARG DEBIAN_VERSION=buster
ARG GO_VERSION=1.15

FROM golang:${GO_VERSION}-${DEBIAN_VERSION} AS go

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
COPY --from=go /usr/local/go /usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    CGO_ENABLED=0 \
    GO111MODULE=on
WORKDIR $GOPATH
# Install Debian packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends g++ wget && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -r /var/cache/* /var/lib/apt/lists/*
# Shell setup
COPY --chown=${USER_UID}:${USER_GID} shell/.zshrc-specific shell/.welcome.sh /home/${USERNAME}/
COPY shell/.zshrc-specific shell/.welcome.sh /root/
# Install Go packages
ARG GOLANGCI_LINT_VERSION=v1.33.0
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin -d ${GOLANGCI_LINT_VERSION}
ARG GOPLS_VERSION=v0.5.5
ARG DELVE_VERSION=v1.5.0
ARG GOMODIFYTAGS_VERSION=v1.13.0
ARG GOPLAY_VERSION=v1.0.0
ARG GOTESTS_VERSION=v1.5.3
ARG MOCK_VERSION=v1.4.4
ARG MOCKERY_VERSION=v2.3.0
RUN go get -v \
    # Base Go tools needed for VS code Go extension
    golang.org/x/tools/gopls@${GOPLS_VERSION} \
    golang.org/x/tools/cmd/guru \
    golang.org/x/tools/cmd/gorename \
    github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} \
    # Extra tools integrating with VS code
    github.com/fatih/gomodifytags@${GOMODIFYTAGS_VERSION} \
    github.com/haya14busa/goplay/cmd/goplay@${GOPLAY_VERSION} \
    github.com/cweill/gotests/...@${GOTESTS_VERSION} \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    # Terminal tools
    github.com/golang/mock/gomock@${MOCK_VERSION} \
    github.com/golang/mock/mockgen@${MOCK_VERSION} \
    github.com/vektra/mockery/v2/...@${MOCKERY_VERSION} \
    2>&1 && \
    rm -rf $GOPATH/pkg/* $GOPATH/src/* /root/.cache/go-build && \
    chown -R ${USER_UID}:${USER_GID} $GOPATH && \
    chmod -R 777 $GOPATH

# EXTRA TOOLS
# Kubectl
ARG KUBECTL_VERSION=v1.19.4
RUN wget -qO /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod 500 /usr/local/bin/kubectl && \
    chown ${USERNAME} /usr/local/bin/kubectl
# Stern
ARG STERN_VERSION=1.11.0
RUN wget -qO /usr/local/bin/stern https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_$(uname -s)_amd64 && \
    chown ${USER_UID}:${USER_GID} /usr/local/bin/stern && \
    chmod 500 /usr/local/bin/stern
# Kubectx and Kubens
ARG KUBECTX_VERSION=v0.9.1
RUN wget -qO- "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_$(uname -s)_$(uname -m).tar.gz" | \
    tar -xzC /usr/local/bin kubectx && \
    wget -qO- "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_$(uname -s)_$(uname -m).tar.gz" | \
    tar -xzC /usr/local/bin kubens && \
    chmod 500 /usr/local/bin/kube* && \
    chown ${USERNAME} /usr/local/bin/kube*
# Helm
ARG HELM3_VERSION=v3.3.4
RUN wget -qO- "https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz" | \
    tar -xzC /usr/local/bin --strip-components=1 linux-amd64/helm && \
    chmod 500 /usr/local/bin/helm* && \
    chown ${USERNAME} /usr/local/bin/helm*

USER ${USERNAME}
