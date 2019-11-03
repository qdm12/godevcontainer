# Race

This container contains a fix to run `go test -race` in Alpine Linux.

More information can be found [here](https://github.com/golang/go/issues/14481)

The fix consists in building `go/src/runtime/race/race_linux_amd64.syso` with a patch, this is built in the [Dockerfile](https://github.com/qdm12/godevcontainer/blob/master/Dockerfile#L9) and copied to the final Docker image.
