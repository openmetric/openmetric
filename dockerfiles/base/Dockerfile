FROM centos:7
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

# install su-exec
RUN yum install -y gcc \
	&& curl -fsSL https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c -o /tmp/su-exec.c \
	&& gcc -Wall -Werror -g -o /usr/bin/su-exec /tmp/su-exec.c \
	&& rm -f /tmp/su-exec.c \
	&& yum autoremove -y gcc \
	# carbonapi requires cairo for png rendering
	&& yum install -y cairo \
	# put docs, conf templates, examples, etc. here
	&& mkdir -p /usr/share/openmetric

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

COPY dockerfiles/base/entry.sh /entry.sh
