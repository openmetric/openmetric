#!/bin/bash

TIME=$(date +%Y%m%d%H%M%S)

CARBON_C_RELAY_REPO=https://github.com/grobian/carbon-c-relay.git
CARBON_C_RELAY_REV=v2.6
CARBON_C_RELAY_OUTPUT_DIR=/output/carbon-c-relay
CARBON_C_RELAY_OUTPUT_FILE=relay-$CARBON_C_RELAY_REV-$TIME

GO_CARBON_REPO=https://github.com/lomik/go-carbon.git
GO_CARBON_REV=v0.9.0
GO_CARBON_OUTPUT_DIR=/output/go-carbon
GO_CARBON_OUTPUT_FILE=carbon-$GO_CARBON_REV-$TIME

compile_carbon_c_relay() {
    echo "Compiling carbon-c-relay..."

    git clone $CARBON_C_RELAY_REPO /build/carbon-c-relay
    cd /build/carbon-c-relay
    git checkout $CARBON_C_RELAY_REV
    make relay
    mkdir -pv $CARBON_C_RELAY_OUTPUT_DIR
    cp -v relay $CARBON_C_RELAY_OUTPUT_DIR/$CARBON_C_RELAY_OUTPUT_FILE
    echo "Successfully compiled carbon-c-relay, output: $CARBON_C_RELAY_OUTPUT_DIR/$CARBON_C_RELAY_OUTPUT_FILE"
}

compile_go_carbon() {
    echo "Compiling go-carbon..."

    git clone $GO_CARBON_REPO /build/go-carbon
    cd /build/go-carbon
    git checkout $GO_CARBON_REV
    make submodules
    make
    mkdir -pv $GO_CARBON_OUTPUT_DIR
    cp -v go-carbon $GO_CARBON_OUTPUT_DIR/$GO_CARBON_OUTPUT_FILE
    echo "Successfully compiled go-carbon, output: $GO_CARBON_OUTPUT_DIR/$GO_CARBON_OUTPUT_FILE"
}

while [[ ${#} -gt 0 ]]; do
    case "$1" in
        carbon-c-relay)
            compile_carbon_c_relay
            ;;
        go-carbon)
            compile_go_carbon
            ;;
        all)
            compile_carbon_c_relay
            compile_go_carbon
            ;;
        *)
            echo "Unrecognized build target: $1, please check!"
            exit 1
            ;;
    esac
    shift
done
