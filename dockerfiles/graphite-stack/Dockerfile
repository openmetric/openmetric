FROM frolvlad/alpine-glibc:alpine-3.5
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

# This Dockerfile is used to produce multiple images, controlled via build args
ARG IMAGE_TYPE
ARG CARBON_C_RELAY_VERSION
ARG GO_CARBON_VERSION
ARG CARBONZIPPER_VERSION
ARG CARBONAPI_VERSION
ARG WHISPER_VERSION
ARG CARBONATE_VERSION

# if specified, apk will be instructed to use a local mirror to speed up image building
ARG LOCAL_APK_MIRROR

COPY entry.sh /entry.sh
COPY build.sh /build.sh
RUN /build.sh && rm -f /build.sh

VOLUME ["/openmetric/conf", "/openmetric/log", "/openmetric/data"]

# Since we don't assume which components user would enable, we just expose enough ports
# and let use deside which to use.
EXPOSE 2003-2008 5000

ENTRYPOINT ["/entry.sh"]
