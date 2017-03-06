FROM openmetric/base:centos
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV CARBON_C_RELAY_VERSION=5a15c5b

ENV \
    # by default, we use 4 worker threads
    RELAY_WORKERS=4 \
    RELAY_REMOTES=not-configured \
    RELAY_REPICATION=1

COPY binary/carbon-c-relay/carbon-c-relay-${CARBON_C_RELAY_VERSION}-centos /usr/bin/carbon-c-relay
COPY dockerfiles/carbon-c-relay/relay.conf.default /openmetric/default/relay.conf.default
COPY dockerfiles/carbon-c-relay/carbon-c-relay-wrapper /usr/bin/carbon-c-relay-wrapper
COPY dockerfiles/carbon-c-relay/entry.sh /entry.sh

EXPOSE 2003
VOLUME ["/openmetric/carbon-c-relay/conf", "/openmetric/carbon-c-relay/log"]

ENTRYPOINT ["/entry.sh"]
