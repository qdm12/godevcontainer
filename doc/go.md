# Go

This docker image is based on `golang:1.13-alpine3.11`.

It also contains a custom [race linux module](race.md) to allow running `go test -race` on Alpine.

## Go extension tools

The VS code Go extension requires [several tools](https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on) to fully work.

All Go tools are built as binaries in `/go/bin` and the source code and cache are removed for space efficiency.

The main tool is [Google's Go language server](https://github.com/golang/tools/tree/master/gopls), which is in beta but works quite well and faster than without it.

The other tools integrating with VS code Go extension are:

- [github.com/ramya-rao-a/go-outline](https://github.com/ramya-rao-a/go-outline)
- [github.com/acroca/go-symbols](https://github.com/acroca/go-symbols)
- [github.com/uudashr/gopkgs/cmd/gopkgs](https://github.com/uudashr/gopkgs)
- [golang.org/x/tools/cmd/guru](https://golang.org/x/tools/cmd/guru)
- [golang.org/x/tools/cmd/gorename](https://golang.org/x/tools/cmd/gorename)
- [golang.org/x/lint/golint](https://golang.org/x/lint/golint)
- [github.com/go-delve/delve/cmd/dlv](https://github.com/go-delve/delve/cmd/dlv)
- [github.com/fatih/gomodifytags](https://github.com/fatih/gomodifytags)
- [github.com/haya14busa/goplay](https://github.com/haya14busa/goplay)
- [github.com/josharian/impl](https://github.com/josharian/impl)
- [github.com/tylerb/gotype-live](https://github.com/tylerb/gotype-live)
- [github.com/cweill/gotests](https://github.com/cweill/gotests)
- [github.com/davidrjenni/reftools/cmd/fillstruct](https://github.com/davidrjenni/reftools/cmd/fillstruct)

## Terminal tools

Extra Go binaries tools are installed:

- [github.com/vektra/mockery](https://github.com/vektra/mockery) to generate mocks for testify/mock
- [github.com/kyoh86/scopelint](https://github.com/kyoh86/scopelint) to detect unpinned variables
