FROM openmetric/base:centos
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV GRAFANA_VERSION=v4.1.2

ADD binary/grafana/grafana-${GRAFANA_VERSION}-centos.tar.gz /
COPY dockerfiles/grafana/grafana-wrapper /usr/bin/grafana-wrapper
RUN mkdir -p /etc/grafana \
			&& ln -s /openmetric/grafana/conf/grafana.ini /etc/grafana/grafana.ini

EXPOSE 3000
VOLUME ["/openmetric/grafana/conf", "/openmetric/grafana/log", "/openmetric/grafana/data", "/openmetric/grafana/plugins"]

ENTRYPOINT ["/entry.sh"]
CMD ["grafana-wrapper"]
