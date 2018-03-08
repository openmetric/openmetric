FROM alpine:3.7
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

# This Dockerfile is used to produce multiple images, controlled via `IMAGE_TYPE` arg,
# available types: carbon-c-relay, go-carbon, carbonzipper, carbonapi, tools
ARG IMAGE_TYPE

# For each image type, corresponding component version is required, the version should
# be a valid git ref (i.e. tags, branch names, sha)
ARG CARBON_C_RELAY_VERSION
ARG GO_CARBON_VERSION
ARG CARBONAPI_VERSION
ARG WHISPER_VERSION
ARG CARBONATE_VERSION
ARG GRAFANA_VERSION

# if specified, apk will be instructed to use a local mirror to speed up image building
ARG LOCAL_APK_MIRROR
ARG LOCAL_NPM_MIRROR
ARG LOCAL_NPM_DISTURL_MIRROR

ADD build.sh /build.sh
RUN /build.sh && rm -f /build.sh

ADD entry.sh /entry.sh

VOLUME ["/openmetric/conf", "/openmetric/log", "/openmetric/data"]

ENTRYPOINT ["/entry.sh"]
