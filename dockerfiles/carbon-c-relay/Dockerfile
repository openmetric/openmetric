FROM openmetric/base:centos
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV CARBON_C_RELAY_VERSION=e749aee

ENV \
    # by default, we use 4 worker threads
    RELAY_WORKERS=4 \
    RELAY_REMOTES=not-configured \
    RELAY_REPICATION=1

COPY binary/carbon-c-relay/carbon-c-relay-${CARBON_C_RELAY_VERSION}-centos /usr/bin/carbon-c-relay
COPY dockerfiles/carbon-c-relay/relay.conf.tmpl /usr/share/openmetric/conf/relay.conf.tmpl
COPY dockerfiles/carbon-c-relay/carbon-c-relay-wrapper /usr/bin/carbon-c-relay-wrapper

EXPOSE 2003
VOLUME ["/openmetric/carbon-c-relay/conf", "/openmetric/carbon-c-relay/log"]

ENTRYPOINT ["/entry.sh"]
CMD ["carbon-c-relay-wrapper"]
