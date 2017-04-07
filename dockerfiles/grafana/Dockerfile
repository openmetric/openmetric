FROM grafana/grafana:4.1.2
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

# save grafana official default config files to /usr/share/openmetric/grafana-conf/
RUN mkdir -p /usr/share/openmetric/grafana-conf/ \
	&& cp /etc/grafana/grafana.ini /etc/grafana/ldap.toml /usr/share/openmetric/grafana-conf/ \
	&& ln -snf /openmetric/conf /etc/grafana
COPY dockerfiles/grafana/entry.sh /entry.sh

VOLUME ["/openmetric/conf", "/openmetric/log", "/openmetric/data"]

ENTRYPOINT ["/entry.sh"]
