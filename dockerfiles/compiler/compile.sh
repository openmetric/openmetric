#!/bin/bash

TIME=$(date +%Y%m%d%H%M%S)

source /binary-info

clone_repo() {
    local repo=$1
    local dest=$2
    local rev=$3

    mkdir -p $(dirname $dest)
    git clone $repo $dest
    pushd $dest >/dev/null
    git checkout $rev
    popd >/dev/null
}

compile_carbon_c_relay() {
    echo "Compiling carbon-c-relay..."

    clone_repo $CARBON_C_RELAY_REPO /build/carbon-c-relay $CARBON_C_RELAY_REV

    (cd /build/carbon-c-relay && make relay)
    install -v -D -m 755 /build/carbon-c-relay/relay $CARBON_C_RELAY_OUTPUT

    echo "Successfully compiled carbon-c-relay, output: $CARBON_C_RELAY_OUTPUT"
}

compile_go_carbon() {
    echo "Compiling go-carbon..."

    clone_repo $GO_CARBON_REPO /build/go-carbon $GO_CARBON_REV

    (cd /build/go-carbon && make submodules && make)
    install -v -D -m 755 /build/go-carbon/go-carbon $GO_CARBON_OUTPUT

    echo "Successfully compiled go-carbon, output: $GO_CARBON_OUTPUT"
}

compile_carbonzipper() {
    echo "Compiling carbonzipper..."

    clone_repo $CARBONZIPPER_REPO $GOPATH/src/github.com/dgryski/carbonzipper $CARBONZIPPER_REV

    go get -v github.com/dgryski/carbonzipper
    install -v -D -m 755 $GOPATH/bin/carbonzipper $CARBONZIPPER_OUTPUT

    echo "Successfully compiled carbonzipper, output $CARBONZIPPER_OUTPUT"
}

compile_carbonapi() {
    echo "Compiling carbonapi..."

    clone_repo $CARBONAPI_REPO $GOPATH/src/github.com/dgryski/carbonapi $CARBONAPI_REV

    go get -v github.com/dgryski/carbonapi
    install -v -D -m 755 $GOPATH/bin/carbonapi $CARBONAPI_OUTPUT

    echo "Successfully compiled carbonapi, output $CARBONAPI_OUTPUT"
}

while [[ ${#} -gt 0 ]]; do
    case "$1" in
        carbon-c-relay)
            compile_carbon_c_relay
            ;;
        go-carbon)
            compile_go_carbon
            ;;
        carbonzipper)
            compile_carbonzipper
            ;;
        carbonapi)
            compile_carbonapi
            ;;
        all)
            compile_carbon_c_relay
            compile_go_carbon
            compile_carbonzipper
            compile_carbonapi
            ;;
        *)
            echo "Unrecognized build target: $1, please check!"
            exit 1
            ;;
    esac
    shift
done
