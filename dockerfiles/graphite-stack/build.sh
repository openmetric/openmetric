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
    [ "$IMAGE_TYPE" == "$1" ] && return 0 || return 1
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

setup_runtime_env() {
    # create openmetric user with specific UID, this uid should:
    # * unlikely to exist on host env, so the volume data won't be writable to
    #   regular users on host
    # * be fixed, so when never the docker image updates, files in volumes won't
    #   have wrong permissions.
    adduser -u 990 -g 990 -D -s /bin/sh -h /openmetric openmetric

    if should_install tools; then
        apk add $MIRROR --no-cache python bash
    fi

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

    if should_install tools; then
        BUILD_DEPS="$BUILD_DEPS py-pip build-base python-dev"
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

    # cleanup python pyc files
    find /usr/lib/python2.7/ -name '*.py[co]' -delete || true
    find /usr/lib/python2.7/ -name 'test_*.py' -delete || true
    find /usr/lib/python2.7/ -name 'test_*.py[co]' -delete || true

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
    (cd $src_dir; make)

    echo "Installing carbonapi ..."
    install -v -D -m 755 $src_dir/carbonapi /usr/bin/carbonapi

    # carbonapi requires cairo to support png/svg rendering
    apk add $MIRROR --no-cache cairo
}

compile_and_install_tools() {
    pip install whisper==$WHISPER_VERSION
    pip install \
        --install-option="--prefix=/usr/share/graphite" \
        --install-option="--install-lib=/usr/lib/python2.7/site-packages" \
        --install-option="--install-data=/var/lib/graphite" \
        --install-option="--install-scripts=/usr/bin" \
        carbonate==$CARBONATE_VERSION
}

# check build args
case "$IMAGE_TYPE" in
    carbon-c-relay)
        if [ -z "$CARBON_C_RELAY_VERSION" ]; then
            echo "Missing build arg: CARBON_C_RELAY_VERSION"
            exit 1
        fi
        _COMPILE=compile_and_install_carbon_c_relay
        ;;
    go-carbon)
        if [ -z "$GO_CARBON_VERSION" ]; then
            echo "Missing build arg: GO_CARBON_VERSION"
            exit 1
        fi
        _COMPILE=compile_and_install_go_carbon
        ;;
    carbonzipper)
        if [ -z "$CARBONZIPPER_VERSION" ]; then
            echo "Missing build arg: CARBONZIPPER_VERSION"
            exit 1
        fi
        _COMPILE=compile_and_install_carbonzipper
        ;;
    carbonapi)
        if [ -z "$CARBONAPI_VERSION" ]; then
            echo "Missing build arg: CARBONAPI_VERSION"
            exit 1
        fi
        _COMPILE=compile_and_install_carbonapi
        ;;
    tools)
        if [ -z "$WHISPER_VERSION" ]; then
            echo "Missing build arg WHISPER_VERSION"
            exit 1
        fi
        if [ -z "$CARBONATE_VERSION" ]; then
            echo "Missing build arg CARBONATE_VERSION"
            exit 1
        fi
        _COMPILE=compile_and_install_tools
        ;;
    *)
        echo "Unknown image type: $IMAGE_TYPE"
        exit 1
        ;;
esac

echo "$IMAGE_TYPE" > /image-type

setup_runtime_env
setup_build_env
$_COMPILE
cleanup_build_env
