#!/bin/bash

set -e

export GF_PATHS_DATA=/openmetric/data/grafana
export GF_PATHS_LOGS=/openmetric/log/grafana

copy_default_conf_if_not_exist() {
    conffile="/openmetric/conf/$1"
    dftfile="/usr/share/openmetric/grafana-conf/$1"
    if ! test -f "$conffile"; then
        echo "Config file \"$conffile\" does not exist, using default"
        cp "$dftfile" "$conffile"
    fi
}

create_directory_if_not_exist() {
    if ! test -d "$1"; then
        mkdir -p "$1"
    fi
}

create_directory_if_not_exist "$GF_PATHS_DATA"
create_directory_if_not_exist "$GF_PATHS_LOGS"

copy_default_conf_if_not_exist grafana.ini
copy_default_conf_if_not_exist ldap.toml

exec /run.sh
