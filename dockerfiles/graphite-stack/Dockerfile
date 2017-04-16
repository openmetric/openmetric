FROM frolvlad/alpine-glibc:alpine-3.5
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

# This Dockerfile is used to produce multiple images, controlled via `IMAGE_TYPE` arg,
# available types: carbon-c-relay, go-carbon, carbonzipper, carbonapi, tools
ARG IMAGE_TYPE

# For each image type, corresponding component version is required, the version should
# be a valid git ref (i.e. tags, branch names, sha)
ARG CARBON_C_RELAY_VERSION
ARG GO_CARBON_VERSION
ARG CARBONZIPPER_VERSION
ARG CARBONAPI_VERSION
ARG WHISPER_VERSION
ARG CARBONATE_VERSION

# if specified, apk will be instructed to use a local mirror to speed up image building
ARG LOCAL_APK_MIRROR

COPY build.sh /build.sh
RUN /build.sh && rm -f /build.sh
COPY entry.sh /entry.sh

VOLUME ["/openmetric/conf", "/openmetric/log", "/openmetric/data"]

# Since we don't assume which components user would enable, we just expose enough ports
# and let user decide which to use.

# recommended for carbon-c-relay plain text protocol interface
EXPOSE 2003 2003/udp
# recommended for carbonapi http interface
EXPOSE 5000
# recommended for other components
EXPOSE 2004-2008

ENTRYPOINT ["/entry.sh"]
