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
        exec su-exec openmetric carbon-c-relay -f $CONF/relay.conf -c '-_:#@$'
        ;;
    go-carbon)
        assert_conf_exist carbon.conf
        assert_conf_exist schemas.conf
        exec su-exec openmetric go-carbon --config $CONF/carbon.conf
        ;;
    carbonapi)
        if test -f "$CONF/api.yaml"; then
            echo "Using config file $CONF/api.yaml"
            exec su-exec openmetric carbonapi -config $CONF/api.yaml
        elif test -f "$CONF/api.toml"; then
            echo "Using config file: $CONF/api.toml"
            exec su-exec openmetric carbonapi -config $CONF/api.toml
        else
            echo "Config file not found, nither api.yaml or api.toml"
            exit 1
        fi
        ;;
    grafana)
        assert_conf_exist grafana.conf
        exec su-exec openmetric grafana-server \
            --homepath=/usr/share/grafana \
            --config=$CONF/grafana.conf \
            cfg:default.paths.data="/openmetric/data/grafana" \
            cfg:default.paths.logs="/openmetric/log" \
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
