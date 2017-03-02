FROM alpine:3.5
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV CARBON_C_RELAY_VERSION=5d3a606

ENV \
    # by default, we use 4 worker threads
    RELAY_WORKERS=4 \
    RELAY_REMOTES=not-configured \
    RELAY_REPICATION=1

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
		"/openmetric/carbon-c-relay/conf" \
		"/openmetric/carbon-c-relay/log" \
	&& chown openmetric:openmetric -R /openmetric/carbon-c-relay

COPY binary/carbon-c-relay/carbon-c-relay-${CARBON_C_RELAY_VERSION}-alpine /usr/bin/carbon-c-relay
COPY dockerfiles/carbon-c-relay/relay.conf.default /openmetric/default/relay.conf.default
COPY dockerfiles/carbon-c-relay/carbon-c-relay-wrapper /usr/bin/carbon-c-relay-wrapper
COPY dockerfiles/carbon-c-relay/entry.sh /entry.sh

EXPOSE 2003
VOLUME ["/openmetric/carbon-c-relay/conf", "/openmetric/carbon-c-relay/log"]

ENTRYPOINT ["/entry.sh"]
