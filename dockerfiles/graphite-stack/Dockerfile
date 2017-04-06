FROM centos:7
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

ENV CARBON_C_RELAY_VERSION=v2.6 \
	GO_CARBON_VERSION=v0.9.1 \
	CARBONZIPPER_VERSION=a972ec5 \
	CARBONAPI_VERSION=e6356f3

# create openmetric user with specific UID, this uid should:
# * unlikely to exist on host env, so the volume data won't be accessible to
#   regular users on host
# * be fixed, so when never the docker image updates, files in volumes won't
#   have wrong permissions.
RUN groupadd -g 990 openmetric \
	&& useradd \
		-m -d /openmetric \
		-s /bin/bash \
		-u 990 -g 990 \
		openmetric

# install su-exec
RUN yum install -y gcc \
	&& curl -fsSL https://raw.githubusercontent.com/ncopa/su-exec/f85e5bd/su-exec.c -o /tmp/su-exec.c \
	&& gcc -Wall -Werror -g -o /usr/bin/su-exec /tmp/su-exec.c \
	&& rm -f /tmp/su-exec.c \
	&& yum autoremove -y gcc \
	# carbonapi requires cairo for png rendering
	&& yum install -y cairo \
	# install supervisor
	&& yum install -y epel-release \
	&& yum install -y supervisor \
	&& sed -i 's/nodaemon=false/nodaemon=true/g' /etc/supervisord.conf \
	&& sed -i 's@logfile=[^ ]\+@logfile=/openmetric/log/supervisord.log@g' /etc/supervisord.conf \
	&& chown openmetric:openmetric /var/run/supervisor/ \
	&& yum clean all

# Install binaries
COPY binary/carbon-c-relay/carbon-c-relay-${CARBON_C_RELAY_VERSION}-centos /usr/bin/carbon-c-relay
COPY binary/go-carbon/go-carbon-${GO_CARBON_VERSION}-centos /usr/bin/go-carbon
COPY binary/carbonzipper/carbonzipper-${CARBONZIPPER_VERSION}-centos /usr/bin/carbonzipper
COPY binary/carbonapi/carbonapi-${CARBONAPI_VERSION}-centos /usr/bin/carbonapi
COPY dockerfiles/graphite-stack/carbonapi-wrapper /usr/bin/carbonapi-wrapper
COPY dockerfiles/graphite-stack/entry.sh /entry.sh

# Add supervisor conf files
COPY dockerfiles/graphite-stack/supervisor.d /openmetric/supervisor.d

# Directory Layout
# /openmetric/
#   |- conf/
#       |- relay.conf, carbon.conf, schemas.conf, zipper.conf, supervisor.conf
#   |- log/
#       |- relay.log, carbon.log, zipper.log, api.log, supervisord.log
#   |- data/
#       |- whisper
RUN mkdir -p /openmetric/conf /openmetric/log /openmetric/data \
	&& chown openmetric:openmetric -R /openmetric/
VOLUME ["/openmetric/conf", "/openmetric/log", "/openmetric/data"]

# Add default configuration files
COPY example-conf/standalone/ /usr/share/openmetric/default-conf/

# Since we don't assume which components user would enable, we just expose enough ports
# and let use deside which to use.
EXPOSE 2003-2008 5000

ENTRYPOINT ["/entry.sh"]
