#!/bin/bash

CARBON_C_RELAY_REPO=https://github.com/grobian/carbon-c-relay.git
CARBON_C_RELAY_REV=v2.6
CARBON_C_RELAY_OUTPUT=/output/carbon-c-relay

compile_carbon_c_relay() {
    echo "Compiling carbon-c-relay..."
    TIME=$(date +%Y%m%d%H%M%S)

    git clone $CARBON_C_RELAY_REPO /build/carbon-c-relay
    cd /build/carbon-c-relay
    git checkout $CARBON_C_RELAY_REV
    make relay
    mkdir -pv $CARBON_C_RELAY_OUTPUT
    cp -v relay $CARBON_C_RELAY_OUTPUT/relay-$CARBON_C_RELAY_REV-$TIME
    echo "Successfully compiled carbon-c-relay, output: $CARBON_C_RELAY_OUTPUT/relay-$CARBON_C_RELAY_REV-$TIME"
}

while [[ ${#} -gt 0 ]]; do
    case "$1" in
        carbon-c-relay)
            compile_carbon_c_relay
            ;;
        all)
            compile_carbon_c_relay
            ;;
        *)
            echo "Unrecognized build target: $1, please check!"
            exit 1
            ;;
    esac
    shift
done
