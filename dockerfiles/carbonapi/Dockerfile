FROM alpine:3.5
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV CARBONZIPPER_VERSION=a972ec5
ENV CARBONAPI_VERSION=e6356f3

ENV \
    # internal metric report url, format "host:port"
    GRAPHITE_URL="" \
    # zipper backends, should be valid json list (excluding outer bracket),
    # e.g. '"http://go-carbon-1:8080", "http://go-carbon-2:8080"'
    ZIPPER_BACKENDS=""

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

COPY binary/carbonzipper/carbonzipper-${CARBONZIPPER_VERSION}-alpine /usr/bin/carbonzipper
COPY binary/carbonapi/carbonapi-${CARBONAPI_VERSION}-alpine /usr/bin/carbonapi
COPY dockerfiles/carbonapi/zipper.conf.default /openmetric/default/zipper.conf.default
COPY dockerfiles/carbonapi/carbonapi-wrapper /usr/bin/carbonapi-wrapper
COPY dockerfiles/carbonapi/entry.sh /entry.sh

EXPOSE 5000
VOLUME ["/openmetric/carbonapi/conf", "/openmetric/carbonapi/log"]

ENTRYPOINT ["/entry.sh"]
