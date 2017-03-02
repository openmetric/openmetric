FROM alpine:3.5
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


# NOTE, create the user with specific UID, this uid should:
# * unlikely to exist on host env, so the volume data won't be accessible to
#   regular users on host
# * be fixed, so when never the docker image updates, files in volumes won't
#   have wrong permissions.
RUN apk add --no-cache bash su-exec \
	&& adduser \
		-h /openmetric \
		-s /bin/bash \
		-D \
		-u 998 \
		openmetric openmetric

RUN mkdir -pv \
		"/openmetric/go-carbon/data" \
		"/openmetric/go-carbon/conf" \
		"/openmetric/go-carbon/log" \
	&& chown openmetric:openmetric -R /openmetric/go-carbon

COPY binary/go-carbon/go-carbon-${GO_CARBON_VERSION}-alpine /usr/bin/go-carbon
COPY dockerfiles/go-carbon/carbon.conf.default /openmetric/default/carbon.conf.default
COPY dockerfiles/go-carbon/schemas.conf.default /openmetric/default/schemas.conf.default
COPY dockerfiles/go-carbon/go-carbon-wrapper /usr/bin/go-carbon-wrapper
COPY dockerfiles/go-carbon/entry.sh /entry.sh

EXPOSE 2003 8080
VOLUME ["/openmetric/go-carbon/data", "/openmetric/go-carbon/log", "/openmetric/go-carbon/conf"]

ENTRYPOINT ["/entry.sh"]
