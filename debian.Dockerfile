ARG BASEDEV_VERSION=v0.28.0
ARG DEBIAN_VERSION=bookworm
ARG GO_VERSION=1.25
ARG GOMODIFYTAGS_VERSION=v1.17.0
ARG GOPLAY_VERSION=v1.0.0
ARG GOTESTS_VERSION=v1.6.0
ARG DLV_VERSION=v1.25.1
ARG MOCKERY_VERSION=v3.5.2
ARG GOMOCK_VERSION=v1.6.0
ARG MOCKGEN_VERSION=v1.6.0
ARG GOPLS_VERSION=v0.20.0
ARG GOFUMPT_VERSION=v0.8.0
ARG GOLANGCILINT_VERSION=v2.4.0
ARG IMPL_VERSION=v1.2.0
ARG GOPKGS_VERSION=v2.1.2
ARG KUBECTL_VERSION=v1.33.4
ARG STERN_VERSION=v1.32.0
ARG KUBECTX_VERSION=v0.9.5
ARG KUBENS_VERSION=v0.9.5
ARG HELM_VERSION=v3.18.5


FROM golang:${GO_VERSION}-${DEBIAN_VERSION} AS go
FROM ghcr.io/qdm12/binpot:gomodifytags-${GOMODIFYTAGS_VERSION} AS gomodifytags
FROM ghcr.io/qdm12/binpot:goplay-${GOPLAY_VERSION} AS goplay
FROM ghcr.io/qdm12/binpot:gotests-${GOTESTS_VERSION} AS gotests
FROM ghcr.io/qdm12/binpot:dlv-${DLV_VERSION} AS dlv
FROM ghcr.io/qdm12/binpot:mockery-${MOCKERY_VERSION} AS mockery
FROM ghcr.io/qdm12/binpot:gomock-${GOMOCK_VERSION} AS gomock
FROM ghcr.io/qdm12/binpot:mockgen-${MOCKGEN_VERSION} AS mockgen
FROM ghcr.io/qdm12/binpot:gopls-${GOPLS_VERSION} AS gopls
FROM ghcr.io/qdm12/binpot:gofumpt-${GOFUMPT_VERSION} AS gofumpt
FROM ghcr.io/qdm12/binpot:golangci-lint-${GOLANGCILINT_VERSION} AS golangci-lint
FROM ghcr.io/qdm12/binpot:impl-${IMPL_VERSION} AS impl
FROM ghcr.io/qdm12/binpot:gopkgs-${GOPKGS_VERSION} AS gopkgs
FROM ghcr.io/qdm12/binpot:kubectl-${KUBECTL_VERSION} AS kubectl
FROM ghcr.io/qdm12/binpot:stern-${STERN_VERSION} AS stern
FROM ghcr.io/qdm12/binpot:kubectx-${KUBECTX_VERSION} AS kubectx
FROM ghcr.io/qdm12/binpot:kubens-${KUBENS_VERSION} AS kubens
FROM ghcr.io/qdm12/binpot:helm-${HELM_VERSION} AS helm

FROM ghcr.io/qdm12/basedevcontainer:${BASEDEV_VERSION}-debian
ARG CREATED
ARG COMMIT
ARG VERSION=local
LABEL \
    org.opencontainers.image.authors="quentin.mcgaw@gmail.com" \
    org.opencontainers.image.created=$CREATED \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.url="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.documentation="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.source="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.title="Go Dev container Debian" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Dev Containers development"
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
COPY shell/.zshrc-specific shell/.welcome.sh /root/

COPY --from=gomodifytags /bin /go/bin/gomodifytags
COPY --from=goplay  /bin /go/bin/goplay
COPY --from=gotests /bin /go/bin/gotests
COPY --from=dlv /bin /go/bin/dlv
COPY --from=mockery /bin /go/bin/mockery
COPY --from=gomock /bin /go/bin/gomock
COPY --from=mockgen /bin /go/bin/mockgen
COPY --from=gopls /bin /go/bin/gopls
COPY --from=gofumpt /bin /go/bin/gofumpt
COPY --from=golangci-lint /bin /go/bin/golangci-lint
COPY --from=impl /bin /go/bin/impl
COPY --from=gopkgs /bin /go/bin/gopkgs

# Extra binary tools
COPY --from=kubectl /bin /usr/local/bin/kubectl
COPY --from=stern /bin /usr/local/bin/stern
COPY --from=kubectx /bin /usr/local/bin/kubectx
COPY --from=kubens /bin /usr/local/bin/kubens
COPY --from=helm /bin /usr/local/bin/helm
