#!/bin/bash
set -e

GOLANG_VERSION=1.6.4
GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
GOLANG_DOWNLOAD_SHA256=b58bf5cede40b21812dfa031258db18fc39746cc0972bc26dae0393acc377aaf

# carbon-c-relay build dependencies: git make gcc
yum -y install git make gcc

# install golang
if [[ ! -e /build/golang.tar.gz ]]; then
    echo "Downloading golang tarball: $GOLANG_DOWNLOAD_URL"
    curl -fsSL "$GOLANG_DOWNLOAD_URL" -o /build/golang.tar.gz
else
    echo "Find local cache of golang tarball: /build/golang.tar.gz"
fi
echo "$GOLANG_DOWNLOAD_SHA256  /build/golang.tar.gz" | sha256sum -c -
tar -C /usr/local -xzf /build/golang.tar.gz

if [[ -n "$GOPATH" ]]; then
    mkdir -p "$GOPATH/src" "$GOPATH/bin"
fi
