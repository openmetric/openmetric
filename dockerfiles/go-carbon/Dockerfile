FROM openmetric/base:centos
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV GO_CARBON_VERSION=v0.9.1

ENV \
    # by default, only TCP plain protocol listener is enabled, carbon-c-relay talks to
    # go-carbon with TCP plain protocol.
    ENABLE_UDP=false \
    ENABLE_TCP=true \
    ENABLE_PICKLE=false \
    # by default, carbonserver is enabled, carbonzipper talks with carbonserver protocol.
    ENABLE_CARBONSERVER=true \
    # by default, carbonlink is disabled, graphite-api, graphite-web talks with carbonlink,
    # however, we don't use them by default
    ENABLE_CARBONLINK=false

COPY binary/go-carbon/go-carbon-${GO_CARBON_VERSION}-centos /usr/bin/go-carbon
COPY dockerfiles/go-carbon/carbon.conf.default /openmetric/default/carbon.conf.default
COPY dockerfiles/go-carbon/schemas.conf.default /openmetric/default/schemas.conf.default
COPY dockerfiles/go-carbon/go-carbon-wrapper /usr/bin/go-carbon-wrapper
COPY dockerfiles/go-carbon/entry.sh /entry.sh

EXPOSE 2003 8080
VOLUME ["/openmetric/go-carbon/data", "/openmetric/go-carbon/log", "/openmetric/go-carbon/conf"]

ENTRYPOINT ["/entry.sh"]
