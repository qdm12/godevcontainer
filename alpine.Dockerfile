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
# Install Go packages
ARG GOLANGCI_LINT_VERSION=v1.40.1
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin -d ${GOLANGCI_LINT_VERSION}
ARG GOPLS_VERSION=v0.6.11
ARG DELVE_VERSION=v1.6.1
ARG GOMODIFYTAGS_VERSION=v1.13.0
ARG GOPLAY_VERSION=v1.0.0
ARG GOTESTS_VERSION=v1.5.3
ARG MOCK_VERSION=v1.5.0
ARG MOCKERY_VERSION=v2.3.0
RUN go get -v golang.org/x/tools/gopls@${GOPLS_VERSION} 2>&1 && \
    rm -rf $GOPATH/pkg/* $GOPATH/src/* /root/.cache/go-build && \
    chmod -R 777 $GOPATH
RUN go get -v \
    # Base Go tools needed for VS code Go extension
    github.com/ramya-rao-a/go-outline \
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
    chmod -R 777 $GOPATH

# Extra binary tools
COPY --from=kubectl /tmp/kubectl /usr/local/bin/
COPY --from=stern /tmp/stern /usr/local/bin/
COPY --from=kubectx /tmp/kubectx /usr/local/bin/
COPY --from=kubectx /tmp/kubens /usr/local/bin/kubens
COPY --from=helm /tmp/helm /usr/local/bin/helm
