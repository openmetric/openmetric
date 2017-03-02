FROM alpine:3.5
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

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

RUN apk add --no-cache python py-pip \
		# `pip install carbonate` requires gcc
		build-base \
		python-dev \
		ca-certificates \
	&& pip install whisper==0.9.5 \
	&& pip install \
		--install-option="--prefix=/usr/share/graphite" \
		--install-option="--install-lib=/usr/lib/python2.7/site-packages" \
		--install-option="--install-data=/var/lib/graphite" \
		--install-option="--install-scripts=/usr/bin" \
		carbonate==0.2.3 \
	&& apk del build-base python-dev py-pip \
	&& find /usr/lib/python2.7/ -name '*.pyc' -delete \
	&& rm -rf /usr/include

USER openmetric
WORKDIR /openmetric
ENTRYPOINT ["bash"]
