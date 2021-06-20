ARG ALPINE_VERSION=3.13
ARG GO_VERSION=1.16

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS go

ARG BUILDPLATFORM=linux/amd64

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS gobuilder
ENV CGO_ENABLED=0
RUN apk add --no-cache git && \
    git config --global advice.detachedHead false
COPY --from=qmcgaw/xcputranslate:v0.4.0 /xcputranslate /usr/local/bin/xcputranslate
WORKDIR /tmp/build
ARG TARGETPLATFORM

FROM gobuilder AS fillstruct
RUN git clone --depth 1 https://github.com/davidrjenni/reftools.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/fillstruct ./cmd/fillstruct && \
    chmod 500 /tmp/fillstruct

FROM gobuilder AS go-outline
RUN git clone --depth 2 https://github.com/ramya-rao-a/go-outline.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/go-outline && \
    chmod 500 /tmp/go-outline

FROM gobuilder AS gomodifytags
ARG GOMODIFYTAGS_VERSION=v1.13.0
RUN git clone --depth 1 --branch ${GOMODIFYTAGS_VERSION} https://github.com/fatih/gomodifytags.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/gomodifytags && \
    chmod 500 /tmp/gomodifytags

FROM gobuilder AS goplay
ARG GOPLAY_VERSION=v1.0.0
RUN git clone --depth 1 --branch ${GOPLAY_VERSION} https://github.com/haya14busa/goplay.git .
RUN go mod init github.com/haya14busa/goplay && \
    go mod tidy
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/goplay ./cmd/goplay && \
    chmod 500 /tmp/goplay

FROM gobuilder AS gotests
ARG GOTESTS_VERSION=v1.5.3
RUN git clone --depth 1 --branch ${GOTESTS_VERSION} https://github.com/cweill/gotests.git .
RUN go mod init github.com/cweill/gotests && \
    go mod tidy
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/gotests && \
    chmod 500 /tmp/gotests

FROM gobuilder AS dlv
ARG DELVE_VERSION=v1.6.1
RUN if [ "$TARGETPLATFORM" == "linux/amd64" ] || [ "$TARGETPLATFORM" == "linux/arm64" ]; then touch /tmp/isSupported; fi
RUN if [ -f /tmp/isSupported ]; then git clone --depth 1 --branch ${DELVE_VERSION} https://github.com/go-delve/delve.git .; fi
RUN if [ -f /tmp/isSupported ]; then \
        GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
        GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
        go build -trimpath -ldflags="-s -w" -o /tmp/dlv ./cmd/dlv; \
    else \
        echo -e "#!/bin/sh\necho 'dlv is not supported on this platform'\n" > /tmp/dlv; \
    fi && \
    chmod 500 /tmp/dlv

FROM gobuilder AS mockery
ARG MOCKERY_VERSION=v2.3.0
RUN git clone --depth 1 --branch ${MOCKERY_VERSION} https://github.com/vektra/mockery.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/mockery && \
    chmod 500 /tmp/mockery

FROM gobuilder AS gomock
ARG MOCK_VERSION=v1.6.0
RUN git clone --depth 1 --branch ${MOCK_VERSION} https://github.com/golang/mock.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/gomock ./gomock && \
    chmod 500 /tmp/gomock
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/mockgen ./mockgen && \
    chmod 500 /tmp/mockgen

FROM gobuilder AS tools
ARG GOPLS_VERSION=v0.7.0
RUN git clone --depth 1 --branch "gopls/${GOPLS_VERSION}" https://github.com/golang/tools.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/guru golang.org/x/tools/cmd/guru && \
    chmod 500 /tmp/guru
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/gorename golang.org/x/tools/cmd/gorename && \
    chmod 500 /tmp/gorename
RUN cd gopls && \
    GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w" -o /tmp/gopls golang.org/x/tools/gopls && \
    chmod 500 /tmp/gopls

FROM gobuilder AS golangci-lint
ARG GOLANGCI_LINT_VERSION=v1.41.1
RUN git clone --depth 1 --branch ${GOLANGCI_LINT_VERSION} https://github.com/golangci/golangci-lint.git .
RUN COMMIT="$(git rev-parse --short HEAD)" && \
    DATE="$(date +%Y-%m-%dT%T%z)" && \
    GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w \
    -X 'main.version==${GOLANGCI_LINT_VERSION}' \
    -X 'main.commit=${COMMIT}' \
    -X 'main.date=${DATE}' \
    " -o /tmp/golangci-lint ./cmd/golangci-lint && \
    chmod 500 /tmp/golangci-lint

FROM gobuilder AS kubectl
ARG KUBERNETES_VERSION=v1.21.1
RUN git clone --depth 1 --branch ${KUBERNETES_VERSION} https://github.com/kubernetes/kubernetes.git .
RUN SOURCE_DATE_EPOCH="$(git show -s --format=format:%ct HEAD)" && \
    BUILD_DATE="$(date ${SOURCE_DATE_EPOCH:+"--date=@${SOURCE_DATE_EPOCH}"} -u +'%Y-%m-%dT%H:%M:%SZ')" && \
    GITCOMMIT="$(git rev-parse HEAD)" && \
    GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    # Ldflags: see https://github.com/kubernetes/kubernetes/blob/ea0764452222146c47ec826977f49d7001b0ea8c/hack/lib/version.sh#L151
    go build -trimpath -ldflags="-s -w \
    -X 'k8s.io/client-go/pkg/version.buildDate=${BUILD_DATE}' \
    -X 'k8s.io/client-go/pkg/version.gitCommit=${GITCOMMIT}' \
    -X 'k8s.io/client-go/pkg/version.gitTreeState=clean' \
    -X 'k8s.io/client-go/pkg/version.gitVersion=${KUBERNETES_VERSION}' \
    -X 'k8s.io/client-go/pkg/version.gitMajor=1' \
    -X 'k8s.io/client-go/pkg/version.gitMinor=29' \
    -X 'k8s.io/component-base/version.buildDate=${BUILD_DATE}' \
    -X 'k8s.io/component-base/version.gitCommit=${GITCOMMIT}' \
    -X 'k8s.io/component-base/version.gitTreeState=clean' \
    -X 'k8s.io/component-base/version.gitVersion=${KUBERNETES_VERSION}' \
    -X 'k8s.io/component-base/version.gitMajor=1' \
    -X 'k8s.io/component-base/version.gitMinor=21' \
    " -o /tmp/kubectl cmd/kubectl/kubectl.go && \
    chmod 500 /tmp/kubectl

FROM gobuilder AS stern
ARG STERN_VERSION=v1.18.0
RUN git clone --depth 1 --branch ${STERN_VERSION} https://github.com/stern/stern.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w \
    -X 'github.com/stern/stern/cmd.version=${STERN_VERSION}' \
    " -o /tmp/stern && \
    chmod 500 /tmp/stern

FROM gobuilder AS kubectx
ARG KUBECTX_VERSION=v0.9.3
RUN git clone --depth 1 --branch ${KUBECTX_VERSION} https://github.com/ahmetb/kubectx.git .
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w \
    -X 'github.com/ahmetb/kubectx/cmd/kubectx.version=${KUBECTX_VERSION}' \
    " -o /tmp/kubectx ./cmd/kubectx && \
    chmod 500 /tmp/kubectx
RUN GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w \
    -X 'github.com/ahmetb/kubectx/cmd/kubens.version=${KUBECTX_VERSION}' \
    " -o /tmp/kubens ./cmd/kubens && \
    chmod 500 /tmp/kubens

FROM gobuilder AS helm
ARG HELM_VERSION=v3.6.0
RUN git clone --depth 1 --branch ${HELM_VERSION} https://github.com/helm/helm.git .
RUN GITCOMMIT="$(git rev-parse HEAD)" && \
    GOARCH="$(xcputranslate -field arch -targetplatform ${TARGETPLATFORM})" \
    GOARM="$(xcputranslate -field arm -targetplatform ${TARGETPLATFORM})" \
    go build -trimpath -ldflags="-s -w \
    -X 'helm.sh/helm/v3/internal/version.version=${HELM_VERSION}' \
    -X 'helm.sh/helm/v3/internal/version.gitCommit=${GITCOMMIT}' \
    -X 'helm.sh/helm/v3/internal/version.gitTreeState=clean' \
    " -o /tmp/helm ./cmd/helm && \
    chmod 500 /tmp/helm

FROM qmcgaw/basedevcontainer:alpine
ARG BUILD_DATE
ARG COMMIT
ARG VERSION=local
LABEL \
    org.opencontainers.image.authors="quentin.mcgaw@gmail.com" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.url="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.documentation="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.source="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.title="Go Dev container Alpine" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Remote Containers development"
COPY --from=go /usr/local/go /usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    CGO_ENABLED=0 \
    GO111MODULE=on
WORKDIR $GOPATH
# Install Alpine packages (g++ for race testing)
RUN apk add -q --update --progress --no-cache g++
# Shell setup
COPY shell/.zshrc-specific shell/.welcome.sh /root/

COPY --from=fillstruct /tmp/fillstruct /go/bin/
COPY --from=go-outline /tmp/go-outline /go/bin/
COPY --from=gomodifytags /tmp/gomodifytags /go/bin/
COPY --from=goplay /tmp/goplay /go/bin/
COPY --from=gotests /tmp/gotests /go/bin/
COPY --from=dlv /tmp/dlv /go/bin/
COPY --from=mockery /tmp/mockery /go/bin/
COPY --from=gomock /tmp/gomock /go/bin/
COPY --from=gomock /tmp/mockgen /go/bin/
COPY --from=tools /tmp/gopls /go/bin/
COPY --from=tools /tmp/gorename /go/bin/
COPY --from=tools /tmp/guru /go/bin/
COPY --from=golangci-lint /tmp/golangci-lint /go/bin/

# Extra binary tools
COPY --from=kubectl /tmp/kubectl /usr/local/bin/
COPY --from=stern /tmp/stern /usr/local/bin/
COPY --from=kubectx /tmp/kubectx /usr/local/bin/
COPY --from=kubectx /tmp/kubens /usr/local/bin/
COPY --from=helm /tmp/helm /usr/local/bin/
