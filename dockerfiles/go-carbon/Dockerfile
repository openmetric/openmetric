FROM alpine:3.5
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV GO_CARBON_VERSION=v0.9.1

COPY binary/go-carbon/go-carbon-${GO_CARBON_VERSION}-alpine /usr/bin/go-carbon

RUN apk add --no-cache bash su-exec \
	&& adduser \
		-h /openmetric \
		-s /bin/bash \
		-D \
		openmetric openmetric

RUN mkdir -pv \
		"/openmetric/default" \
		"/openmetric/go-carbon/data" \
		"/openmetric/go-carbon/log" \
		"/openmetric/go-carbon/conf" \
	&& chown openmetric:openmetric -R /openmetric/default /openmetric/go-carbon

VOLUME ["/openmetric/go-carbon/data", "/openmetric/go-carbon/log", "/openmetric/go-carbon/conf"]
EXPOSE 2003

COPY dockerfiles/go-carbon/go-carbon-wrapper /usr/bin/go-carbon-wrapper
COPY dockerfiles/go-carbon/entry.sh /entry.sh
COPY dockerfiles/go-carbon/carbon.conf.default /openmetric/default/carbon.conf.default
COPY dockerfiles/go-carbon/schemas.conf.default /openmetric/default/schemas.conf.default
ENTRYPOINT ["/bin/bash", "/entry.sh"]
