ARG BASEDEV_VERSION=v0.30.0
ARG ALPINE_VERSION=3.24
ARG GO_VERSION=1.26
ARG GOMODIFYTAGS_VERSION=v1.17.0
ARG GOPLAY_VERSION=v1.0.0
ARG GOTESTS_VERSION=v1.9.0
ARG DLV_VERSION=v1.27.2
ARG MOCKERY_VERSION=v3.8.0
ARG GOMOCK_VERSION=v0.6.0
ARG MOCKGEN_VERSION=v0.6.0
ARG GOPLS_VERSION=v0.23.0
ARG GOFUMPT_VERSION=v0.12.0
ARG GOLANGCILINT_VERSION=v2.14.0
ARG IMPL_VERSION=v1.5.0
ARG GOPKGS_VERSION=v2.1.2
ARG KUBECTL_VERSION=v1.37.1
ARG STERN_VERSION=v1.34.0
ARG KUBECTX_VERSION=v0.11.0
ARG KUBENS_VERSION=v0.11.0
ARG HELM_VERSION=v4.1.3


FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS go
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

FROM ghcr.io/qdm12/basedevcontainer:${BASEDEV_VERSION}-alpine
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
    org.opencontainers.image.title="Go Dev container Alpine" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Dev Containers development"
# The base image creates and runs an unprivileged account (uid/gid 1000 by default,
# named `user`). These build arguments mirror it so the paths below follow the account
# you build with: keep them in sync with the "remoteUser" key and the mount targets in
# devcontainer.json.
ARG USERNAME=user
ARG GROUP_NAME=user
ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_HOME=/home/${USERNAME}

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    CGO_ENABLED=0 \
    GO111MODULE=on

# Only this block needs root, the rest of the build runs as the unprivileged account,
# like the container does.
USER root
# Group ID of the `docker` group on the host, needed to open a rootful engine's
# /var/run/docker.sock. The published base image has no such group, so create it here.
# Left empty, the group is not created. Alternatively pass
# --group-add=$(stat -c %g /var/run/docker.sock) to the container, no rebuild needed.
ARG DOCKER_GID=
RUN set -eux && \
    if [ -n "${DOCKER_GID}" ] && ! grep -q "^docker:" /etc/group; then \
    addgroup -g "${DOCKER_GID}" docker && \
    addgroup "${USERNAME}" docker; \
    fi && \
    # Go workspace: the unprivileged account builds into it (go mod download, go install)
    mkdir -p "${GOPATH}/bin" "${GOPATH}/pkg" && \
    chown "${USER_UID}:${USER_GID}" "${GOPATH}" "${GOPATH}/bin" "${GOPATH}/pkg"
USER ${USERNAME}

COPY --from=go /usr/local/go /usr/local/go
WORKDIR $GOPATH
# Install Alpine packages (g++ for race testing)
RUN apk add -q --update --progress --no-cache g++
# Shell setup
COPY --chown="${USER_UID}:${USER_GID}" --chmod=644 shell/.zshrc-plugins shell/.welcome.sh ${USER_HOME}/
COPY --chown="${USER_UID}:${USER_GID}" --from=gomodifytags /bin /go/bin/gomodifytags
COPY --chown="${USER_UID}:${USER_GID}" --from=goplay  /bin /go/bin/goplay
COPY --chown="${USER_UID}:${USER_GID}" --from=gotests /bin /go/bin/gotests
COPY --chown="${USER_UID}:${USER_GID}" --from=dlv /bin /go/bin/dlv
COPY --chown="${USER_UID}:${USER_GID}" --from=mockery /bin /go/bin/mockery
COPY --chown="${USER_UID}:${USER_GID}" --from=gomock /bin /go/bin/gomock
COPY --chown="${USER_UID}:${USER_GID}" --from=mockgen /bin /go/bin/mockgen
COPY --chown="${USER_UID}:${USER_GID}" --from=gopls /bin /go/bin/gopls
COPY --chown="${USER_UID}:${USER_GID}" --from=gofumpt /bin /go/bin/gofumpt
COPY --chown="${USER_UID}:${USER_GID}" --from=golangci-lint /bin /go/bin/golangci-lint
COPY --chown="${USER_UID}:${USER_GID}" --from=impl /bin /go/bin/impl
COPY --chown="${USER_UID}:${USER_GID}" --from=gopkgs /bin /go/bin/gopkgs

# Extra binary tools
COPY --chown="${USER_UID}:${USER_GID}" --from=kubectl /bin /usr/local/bin/kubectl
COPY --chown="${USER_UID}:${USER_GID}" --from=stern /bin /usr/local/bin/stern
COPY --chown="${USER_UID}:${USER_GID}" --from=kubectx /bin /usr/local/bin/kubectx
COPY --chown="${USER_UID}:${USER_GID}" --from=kubens /bin /usr/local/bin/kubens
COPY --chown="${USER_UID}:${USER_GID}" --from=helm /bin /usr/local/bin/helm
