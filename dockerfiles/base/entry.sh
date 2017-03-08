#!/bin/bash

## This file is the entrypoint and is run as root user, we can fix
## directory permissions and then switch to openmetric user.

set -e

for dir in /openmetric/ /openmetric/*/*; do
    if test -d "$dir"; then
        chown openmetric:openmetric "$dir"
    fi
done

if command -v "$1" >/dev/null; then
    exec su-exec openmetric "$@"
else
    echo "Unknown command: $1"
fi
