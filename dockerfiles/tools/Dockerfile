FROM openmetric/base:centos
MAINTAINER Zhang Cheng <zhangcheng@cmss.chinamobile.com>

RUN yum install -y epel-release \
	&& yum install -y python-pip python-devel gcc \
	&& pip install whisper==0.9.5 \
	&& pip install \
		--install-option="--prefix=/usr/share/graphite" \
		--install-option="--install-lib=/usr/lib/python2.7/site-packages" \
		--install-option="--install-data=/var/lib/graphite" \
		--install-option="--install-scripts=/usr/bin" \
		carbonate==0.2.3 \
	&& yum autoremove -y python-devel gcc

USER openmetric
WORKDIR /openmetric
ENTRYPOINT ["bash"]
