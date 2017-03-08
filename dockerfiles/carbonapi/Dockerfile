FROM openmetric/base:centos
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV CARBONZIPPER_VERSION=a972ec5
ENV CARBONAPI_VERSION=e6356f3

ENV \
    # internal metric report url, format "host:port"
    GRAPHITE_URL="" \
    # zipper backends, should be valid json list (excluding outer bracket),
    # e.g. '"http://go-carbon-1:8080", "http://go-carbon-2:8080"'
    ZIPPER_BACKENDS=""

COPY binary/carbonzipper/carbonzipper-${CARBONZIPPER_VERSION}-centos /usr/bin/carbonzipper
COPY binary/carbonapi/carbonapi-${CARBONAPI_VERSION}-centos /usr/bin/carbonapi
COPY dockerfiles/carbonapi/zipper.conf.tmpl /usr/share/openmetric/conf/zipper.conf.tmpl
COPY dockerfiles/carbonapi/carbonapi-wrapper /usr/bin/carbonapi-wrapper

EXPOSE 5000
VOLUME ["/openmetric/carbonapi/conf", "/openmetric/carbonapi/log"]

ENTRYPOINT ["/entry.sh"]
CMD ["carbonapi-wrapper"]
