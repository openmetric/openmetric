FROM openmetric/base:centos
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV CARBON_C_RELAY_VERSION=5a15c5b \
	GO_CARBON_VERSION=v0.9.1 \
	CARBONZIPPER_VERSION=a972ec5 \
	CARBONAPI_VERSION=e6356f3 \
	GRAFANA_VERSION=v4.1.2

COPY binary/carbon-c-relay/carbon-c-relay-${CARBON_C_RELAY_VERSION}-centos /usr/bin/carbon-c-relay
COPY binary/go-carbon/go-carbon-${GO_CARBON_VERSION}-centos /usr/bin/go-carbon
COPY binary/carbonzipper/carbonzipper-${CARBONZIPPER_VERSION}-centos /usr/bin/carbonzipper
COPY binary/carbonapi/carbonapi-${CARBONAPI_VERSION}-centos /usr/bin/carbonapi
ADD binary/grafana/grafana-${GRAFANA_VERSION}-centos.tar.gz /
COPY dockerfiles/standalone/openmetric-wrapper /usr/bin/openmetric-wrapper

COPY dockerfiles/standalone/relay.conf /usr/share/openmetric/conf/relay.conf.standalone
COPY dockerfiles/standalone/carbon.conf /usr/share/openmetric/conf/carbon.conf.standalone
COPY dockerfiles/standalone/schemas.conf /usr/share/openmetric/conf/schemas.conf.standalone
COPY dockerfiles/standalone/zipper.conf /usr/share/openmetric/conf/zipper.conf.standalone
RUN mkdir -p /etc/grafana \
	&& ln -s /openmetric/grafana/conf/grafana.ini /etc/grafana/grafana.ini

# tcp:2003 & udp:2003 -> carbon-c-relay
# http:3000 -> grafana
# http:5000 -> carbonapi
EXPOSE 2003 3000 5000
VOLUME ["/openmetric"]

ENTRYPOINT ["/entry.sh"]
CMD ["openmetric-wrapper"]
