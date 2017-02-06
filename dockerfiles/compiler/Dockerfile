# This image is only used to compile binaries

FROM centos:7
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

COPY build /build

RUN /build/build-compiler.sh && rm -rf /build

COPY dockerfiles/compiler/compile.sh /compile.sh
VOLUME ["/output"]
CMD ["/compile.sh", "all"]
