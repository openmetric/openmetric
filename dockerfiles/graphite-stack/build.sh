#!/bin/sh

set -e

export GOLANG_VERSION=1.8
export GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
export GOLANG_DOWNLOAD_SHA256=53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca

export GOPATH=/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

if [ -n "$LOCAL_APK_MIRROR" ]; then
    MIRROR="--repository $LOCAL_APK_MIRROR"
else
    MIRROR=""
fi

should_install() {
    case "$1" in
        carbon-c-relay)
            [ -n "$CARBON_C_RELAY_VERSION" ] && return 0 || return 1
            ;;
        go-carbon)
            [ -n "$GO_CARBON_VERSION" ] && return 0 || return 1
            ;;
        carbonzipper)
            [ -n "$CARBONZIPPER_VERSION" ] && return 0 || return 1
            ;;
        carbonapi)
            [ -n "$CARBONAPI_VERSION" ] && return 0 || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

should_install_any() {
    while [ "$#" -gt 0 ]; do
        if should_install $1; then
            return 0
        fi
        shift
    done
    return 1
}

should_install_all() {
    while [ "$#" -gt 0 ]; do
        if ! should_install $1; then
            return 1
        fi
        shift
    done
    return 0
}

should_install_count() {
    count=0
    while [ "$#" -gt 0 ]; do
        if should_install $1; then
            count=$((count+1))
        fi
        shift
    done
    echo $count
}

setup_runtime_env() {
    # create openmetric user with specific UID, this uid should:
    # * unlikely to exist on host env, so the volume data won't be writable to
    #   regular users on host
    # * be fixed, so when never the docker image updates, files in volumes won't
    #   have wrong permissions.
    adduser -u 990 -g 990 -D -s /bin/sh -h /openmetric openmetric

    # install su-exec
    apk add $MIRROR --no-cache su-exec

    # create directory layout
    mkdir -p /openmetric/conf /openmetric/log /openmetric/data
    chown openmetric:openmetric -R /openmetric/
}

# install packages required for compiling packages
setup_build_env() {
    mkdir /build

    local BUILD_DEPS="git mercurial curl ca-certificates make"

    if should_install carbon-c-relay; then
        BUILD_DEPS="$BUILD_DEPS gcc libc-dev bison"
    fi

    if should_install carbonapi; then
        BUILD_DEPS="$BUILD_DEPS cairo-dev gcc libc-dev"
    fi

    # install build requirements
    apk add $MIRROR --no-cache --virtual .build-deps $BUILD_DEPS

    if should_install_any go-carbon carbonzipper carbonapi; then
        echo "Installing go $GOLANG_VERSION ..."
        curl -fsSL "$GOLANG_DOWNLOAD_URL" -o /build/golang.tar.gz
        echo "$GOLANG_DOWNLOAD_SHA256  /build/golang.tar.gz" | sha256sum -c -
        tar -C /usr/local -zxf /build/golang.tar.gz
        mkdir -p "$GOPATH/src" "$GOPATH/bin"
    fi
}

# removes packages not needed for final images
cleanup_build_env() {
    # remove build requirements
    apk del .build-deps
    rm -rf /var/cache/apk/*

    # remove golang
    rm -rf /usr/local/go $GOPATH

    # remove all build cache
    rm -rf /build
}

clone_git_repo() {
    local repo_url=$1
    local src_dir=$2
    local rev=$3

    echo "Cloning repo: $repo_url, rev: $rev ..."
    mkdir -p $(dirname $src_dir)
    git clone $repo_url $src_dir
    (cd $src_dir && git checkout $rev)
}

compile_and_install_carbon_c_relay() {
    local repo_url=https://github.com/grobian/carbon-c-relay.git
    local src_dir=/build/carbon-c-relay

    echo "Compiling carbon-c-relay ..."
    clone_git_repo $repo_url $src_dir $CARBON_C_RELAY_VERSION
    (cd $src_dir && make relay)

    echo "Installing carbon-c-relay"
    install -v -D -m 755 $src_dir/relay /usr/bin/carbon-c-relay
}

compile_and_install_go_carbon() {
    local repo_url=https://github.com/lomik/go-carbon.git
    local src_dir=/build/go-carbon

    echo "Compiling go-carbon ..."
    clone_git_repo $repo_url $src_dir $GO_CARBON_VERSION
    (cd $src_dir && make submodules && make)

    echo "Installing go-carbon ..."
    install -v -D -m 755 $src_dir/go-carbon /usr/bin/go-carbon
}

compile_and_install_carbonzipper() {
    #git config --global url.https://github.com/openmetric/carbonapi.insteadOf https://github.com/go-graphite/carbonapi
    #git config --global url.https://github.com/openmetric/carbonzipper.insteadOf https://github.com/go-graphite/carbonzipper
    local repo_url=https://github.com/go-graphite/carbonzipper.git
    local src_dir=$GOPATH/src/github.com/go-graphite/carbonzipper

    echo "Compiling carbonzipper ..."
    clone_git_repo $repo_url $src_dir $CARBONZIPPER_VERSION
    # UGLY FIX: dep ensure would fail for the first time
    (cd $src_dir; make)

    echo "Installing carbonzipper ..."
    install -v -D -m 755 $src_dir/carbonzipper /usr/bin/carbonzipper
}

compile_and_install_carbonapi() {
    #git config --global url.https://github.com/openmetric/carbonapi.insteadOf https://github.com/go-graphite/carbonapi
    #git config --global url.https://github.com/openmetric/carbonzipper.insteadOf https://github.com/go-graphite/carbonzipper
    local repo_url=https://github.com/go-graphite/carbonapi.git
    local src_dir=$GOPATH/src/github.com/go-graphite/carbonapi

    echo "Compiling carbonapi ..."
    clone_git_repo $repo_url $src_dir $CARBONAPI_VERSION
    # UGLY FIX: dep ensure would fail for the first time
    (cd $src_dir; make)

    echo "Installing carbonapi ..."
    install -v -D -m 755 $src_dir/carbonapi /usr/bin/carbonapi

    # carbonapi requires cairo to support png/svg rendering
    apk add $MIRROR --no-cache cairo
}

determine_image_type() {
    if [ $(should_install_count carbon-c-relay go-carbon carbonzipper carbonapi) -ne 1 ]; then
        echo "Only one or all component can be installed"
        exit 1
    fi

    for comp in carbon-c-relay go-carbon carbonzipper carbonapi; do
        if should_install $comp; then
            echo $comp
            return
        fi
    done
}

compile_and_install() {
    local image_type=$(determine_image_type)
    echo "$image_type" > /image-type

    case "$image_type" in
        carbon-c-relay)
            compile_and_install_carbon_c_relay
            ;;
        go-carbon)
            compile_and_install_go_carbon
            ;;
        carbonzipper)
            compile_and_install_carbonzipper
            ;;
        carbonapi)
            compile_and_install_carbonapi
            ;;
        *)
            echo "Unknown image type"
            exit 1
            ;;
    esac
}

setup_runtime_env
setup_build_env
compile_and_install
cleanup_build_env
