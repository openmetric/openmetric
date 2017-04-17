#!/bin/sh

set -e

# start a single component

# FIX directory permissions and switch user
# Note, don't use "-R" with chown, we only need to fix permission if user attaches new
# data volume to the container, in which case these directories are supposed to be empty.
chown openmetric:openmetric /openmetric/data/ /openmetric/log/

CONF=/openmetric/conf
LOG=/openmetric/log
DATA=/openmetric/data

assert_conf_exist() {
    if ! test -f "$CONF/$1"; then
        echo "Required file does not exist: $1"
        exit 1
    fi
}

# if a command is provided, run that command
if command -v "$1" 2>/dev/null; then
    exec su-exec openmetric "$@"
fi

image_type=$(cat /image-type)

case "$image_type" in
    carbon-c-relay)
        assert_conf_exist relay.conf
        exec su-exec openmetric carbon-c-relay -f $CONF/relay.conf -l $LOG/relay.log -c '-_:#@'
        ;;
    go-carbon)
        assert_conf_exist carbon.conf
        assert_conf_exist schemas.conf
        exec su-exec openmetric go-carbon --config $CONF/carbon.conf
        ;;
    carbonzipper)
        assert_conf_exist zipper.conf
        # for current stable release
        exec su-exec openmetric carbonzipper -c $CONF/zipper.conf -logdir /openmetric/log/
        # for next release
        #exec su-exec openmetric carbonzipper -c $CONF/zipper.conf
        ;;
    carbonapi)
        assert_conf_exist api.conf
        # for current stable release
        source $CONF/api.conf
        exec su-exec openmetric carbonapi \
            -p ${LISTEN_PORT:-5000} \
            -z ${ZIPPER_URL:-127.0.0.1:8080} \
            -graphite ${GRAPHITE_URL:-127.0.0.1:2003} \
            -prefix ${INTERNAL_METRIC_PREFIX:-carbon.api} \
            -i ${INTERVAL:-10s} \
            -logdir ${LOGDIR:-/openmetric/log/}
        # for next release
        #exec su-exec openmetric carbonapi -config $CONF/api.conf
        ;;
    grafana)
        assert_conf_exist grafana.conf
        exec su-exec openmetric grafana-server \
            --homepath=/usr/share/grafana \
            --config=$CONF/grafana.conf \
            cfg:default.paths.data="/openmetric/data/grafana" \
            cfg:default.paths.logs="/openmetric/grafana/log" \
            cfg:default.paths.plugins="/openmetric/data/grafana-plugins"
        ;;
    tools)
        if command -v "$1" 2>/dev/null; then
            exec su-exec openmetric "$@"
        else
            exec su-exec openmetric bash
        fi
        ;;
    *)
        echo "Unknown image type: $image_type"
        exit 1
        ;;
esac
