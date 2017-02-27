#!/bin/bash

## This file is the entrypoint and is run as root user, we can fix
## directory permissions and then switch to openmetric user.

set -e

for subdir in conf data log; do
    dir=/openmetric/go-carbon/$subdir
    if test ! -d "$dir"; then
        mkdir -p "$dir"
        chown openmetric:openmetric "$dir"
    fi
done

exec su-exec openmetric /usr/bin/go-carbon-wrapper
