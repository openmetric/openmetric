# This image is only used to compile binaries

FROM golang:1.8-alpine
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

# install other compiler tools
RUN apk add --no-cache git build-base

# the compiled binaries will be copied to /binary directory
VOLUME ["/binary"]

# /compile.sh is the default command
COPY dockerfiles/compiler/compile.sh /usr/bin/compile
ENTRYPOINT ["/usr/bin/compile"]
