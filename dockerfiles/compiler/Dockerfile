# This image is only used to compile binaries

FROM centos:7
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ARG GOLANG_VERSION=1.8
ARG GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ARG GOLANG_DOWNLOAD_SHA256=53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY cache /cache
# install go
RUN if [ ! -e /cache/golang.tar.gz ]; then \
			echo "Downloading golang tarball: $GOLANG_DOWNLOAD_URL" \
			&& curl -fsSL "$GOLANG_DOWNLOAD_URL" -o /cache/golang.tar.gz \
		;else \
			echo "Find local cache of golang tarball: /cache/golang.tar.gz" \
		;fi \
		&& echo "$GOLANG_DOWNLOAD_SHA256  /cache/golang.tar.gz" | sha256sum -c - \
		&& tar -C /usr/local -zxf /cache/golang.tar.gz \
		&& if [ -n "$GOPATH" ]; then \
				mkdir -p "$GOPATH/src" "$GOPATH/bin" \
			;fi
# install other compiler tools
RUN yum install -y git make gcc
RUN rm -rf /cache

# the compiled binaries will be copied to /binary directory
VOLUME ["/binary"]

# /compile.sh is the default command
COPY dockerfiles/compiler/compile.sh /usr/bin/compile
ENTRYPOINT ["/usr/bin/compile"]
