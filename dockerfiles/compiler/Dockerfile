# This image is only used to compile binaries

FROM centos:7
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY build /build
RUN /build/build-compiler.sh && rm -rf /build

# the compiled binaries will be copied to /output directory
VOLUME ["/output"]

# /compile.sh is the default command
COPY dockerfiles/compiler/compile.sh /compile.sh
CMD ["/compile.sh", "all"]
