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
        exec su-exec openmetric carbonzipper -c $CONF/zipper.conf
        ;;
    carbonapi)
        assert_conf_exist api.yaml
        exec su-exec openmetric carbonapi -config $CONF/api.yaml
        ;;
    *)
        echo "Unknown image type: $image_type"
        exit 1
        ;;
esac
