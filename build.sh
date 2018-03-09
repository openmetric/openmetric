#!/bin/sh

set -e

export GOLANG_VERSION=1.10
export GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
export GOLANG_DOWNLOAD_SHA256=b5a64335f1490277b585832d1f6c7f8c6c11206cba5cd3f771dcb87b98ad1a33

export GOPATH=/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

mkdir /build

if [ -n "$LOCAL_APK_MIRROR" ]; then
    cat /etc/apk/repositories | \
        sed "s@http://dl-cdn.alpinelinux.org/alpine/@$LOCAL_APK_MIRROR@g" \
        > /build/repositories
    alias apk="apk --repositories-file /build/repositories"
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

    # the tools image requires python, and provide bash for better interactive experience
    if should_install tools; then
        apk add --no-cache python bash
    fi

    # su-exec for switching user
    # libc6-compat for running golang
    # curl/netcat for health check
    apk add --no-cache su-exec libc6-compat curl ca-certificates netcat-openbsd

    # create directory layout
    mkdir -p /openmetric/conf /openmetric/log /openmetric/data
    chown openmetric:openmetric -R /openmetric/
}

setup_npm() {
    # set cache dir in /build/, so it can be cleanup easily
    npm config set cache /build/.npm/

    [ -n "$LOCAL_NPM_MIRROR" ] && npm config set registry $LOCAL_NPM_MIRROR
    [ -n "$LOCAL_NPM_DISTURL_MIRROR" ] && npm config set disturl $LOCAL_NPM_DISTURL_MIRROR

    npm install -g yarn
    [ -n "$LOCAL_NPM_MIRROR" ] && yarn config set registry $LOCAL_NPM_MIRROR

    # last [] could fail
    true
}

setup_golang() {
    echo "Installing go $GOLANG_VERSION ..."
    curl -fsSL "$GOLANG_DOWNLOAD_URL" -o /build/golang.tar.gz
    echo "$GOLANG_DOWNLOAD_SHA256  /build/golang.tar.gz" | sha256sum -c -
    tar -C /usr/local -zxf /build/golang.tar.gz
    mkdir -p "$GOPATH/src" "$GOPATH/bin"
}

# install packages required for compiling packages
setup_build_env() {
    local BUILD_DEPS="git mercurial make"
    local REQUIRE_GOLANG=false
    local REQUIRE_NPM=false

    case "$IMAGE_TYPE" in
        carbon-c-relay)
            BUILD_DEPS="$BUILD_DEPS gcc musl-dev bison flex automake autoconf"
            ;;
        go-carbon)
            REQUIRE_GOLANG=true
            ;;
        carbonapi)
            BUILD_DEPS="$BUILD_DEPS gcc musl-dev cairo-dev"
            REQUIRE_GOLANG=true
            ;;
        grafana)
            BUILD_DEPS="$BUILD_DEPS nodejs gcc g++"
            REQUIRE_GOLANG=true
            REQUIRE_NPM=true
            ;;
        tools)
            BUILD_DEPS="$BUILD_DEPS py-pip build-base python-dev"
            ;;
    esac

    # install build dependencies
    apk add --no-cache --virtual .build-deps $BUILD_DEPS

    [ "$REQUIRE_NPM" == "true" ] && setup_npm
    [ "$REQUIRE_GOLANG" == "true" ] && setup_golang

    true
}

# removes packages not needed for final images
cleanup_build_env() {
    # remove build dependencies
    apk del --purge .build-deps

    # clear apk caches
    rm -rf /var/cache/apk/*

    # remove golang, not needed for running go compiled applications
    rm -rf /usr/local/go $GOPATH

    # cleanup python py compiled files, this saves significant space
    find /usr/lib/python2.7/ -name '*.py[co]' -delete || true
    find /usr/lib/python2.7/ -name 'test_*.py' -delete || true
    find /usr/lib/python2.7/ -name 'test_*.py[co]' -delete || true

    # remove all build cache
    rm -rf /build

    # some build tools save files in /root/, remove all files under /root
    find /root -mindepth 1 -maxdepth 1 -exec rm -rf {} \;

    # cleanup other useless directories
    rm -rf /tmp/*
    rm -rf /usr/lib/node_modules/
}

clone_git_repo() {
    local repo_url=$1
    local src_dir=$2
    local rev=$3
    local fast=$4

    echo "Cloning repo: $repo_url, rev: $rev ..."
    mkdir -p $(dirname $src_dir)

    if [ "x$fast" == "xfast" ]; then
        # mimic git clone --depth 1 ..., assume all repos are on github
        local repo_name=$(basename ${repo_url%%.git})
        mkdir /build/git-unzip
        curl -fsSL ${repo_url%%.git}/archive/${rev}.zip -o /build/${repo_name}.zip
        unzip -q -d /build/git-unzip /build/${repo_name}.zip
        mv /build/git-unzip/${repo_name}-* $src_dir
    else
        git clone $repo_url $src_dir
        (cd $src_dir && git checkout $rev)
    fi
}

install_carbon_c_relay() {
    local repo_url=https://github.com/grobian/carbon-c-relay.git
    local src_dir=/build/carbon-c-relay

    if [ "$CARBON_C_RELAY_VERSION" = "edge" ]; then
        CARBON_C_RELAY_VERSION=master
    fi

    echo "Compiling carbon-c-relay ..."
    clone_git_repo $repo_url $src_dir $CARBON_C_RELAY_VERSION

    if [ -f "$src_dir/configure" ]; then
        (cd $src_dir && ./configure && make)
    else
        (cd $src_dir && make relay)
    fi

    echo "Installing carbon-c-relay"
    install -v -D -m 755 $src_dir/relay /usr/bin/carbon-c-relay
}

install_go_carbon() {
    local repo_url=https://github.com/lomik/go-carbon.git
    local src_dir=/build/go-carbon

    if [ "$GO_CARBON_VERSION" = "edge" ]; then
        GO_CARBON_VERSION=master
    fi

    echo "Compiling go-carbon ..."
    clone_git_repo $repo_url $src_dir $GO_CARBON_VERSION
    (cd $src_dir && make submodules && make)

    echo "Installing go-carbon ..."
    install -v -D -m 755 $src_dir/go-carbon /usr/bin/go-carbon
}

install_carbonapi() {
    local repo_url=https://github.com/go-graphite/carbonapi.git
    local src_dir=$GOPATH/src/github.com/go-graphite/carbonapi

    if [ "$CARBONAPI_VERSION" = "edge" ]; then
        CARBONAPI_VERSION=master
    fi

    echo "Compiling carbonapi ..."
    clone_git_repo $repo_url $src_dir $CARBONAPI_VERSION

    local binary_file=""
    if [ -f "$src_dir/Makefile" ]; then
        (cd $src_dir && make)
        binary_file=$src_dir/carbonapi
    else
        go get -v -tags cairo github.com/go-graphite/carbonapi -ldflags "-X main.BuildVersion=${CARBONAPI_VERSION}"
        binary_file=$GOPATH/bin/carbonapi
    fi

    echo "Installing carbonapi ..."
    install -v -D -m 755 $binary_file /usr/bin/carbonapi

    # carbonapi requires cairo to support png/svg rendering
    apk add --no-cache cairo
}

install_grafana() {
    local repo_url=https://github.com/grafana/grafana.git
    local src_dir=$GOPATH/src/github.com/grafana/grafana

    if [ "$GRAFANA_VERSION" = "edge" ]; then
        GRAFANA_VERSION=master
    fi

    echo "Compiling grafana ..."
    clone_git_repo $repo_url $src_dir $GRAFANA_VERSION fast

    (cd $src_dir \
        && go run build.go setup \
        && go run build.go build \
        && yarn install --pure-lockfile \
        && ./node_modules/.bin/grunt release
    )

    echo "Installing grafana ..."
    install -v -D -m 755 $src_dir/tmp/bin/grafana-server /usr/bin/grafana-server
    install -v -D -m 755 $src_dir/tmp/bin/grafana-cli /usr/bin/grafana-cli
    install -v -d -m 755 /usr/share/grafana
    cp -r $src_dir/tmp/public /usr/share/grafana/public
    cp -r $src_dir/tmp/conf /usr/share/grafana/conf

    # these cleanup jobs are not suitable to do in global cleanup_build_env()
    find /usr/share/grafana/ -name '*.js.map' -delete
    npm uninstall -g yarn
    # yarn cache files
    rm -rf /usr/local/share/.cache/
}

install_tools() {
    local _whisper_pkg=""
    if [ "$WHISPER_VERSION" = "edge" ]; then
        _whisper_pkg="git+https://github.com/graphite-project/whisper.git@master#egg=whisper"
    else
        _whisper_pkg="whisper==$WHISPER_VERSION"
    fi
    pip install "${_whisper_pkg}"

    local _carbonate_pkg=""
    if [ "$CARBONATE_VERSION" = "edge" ]; then
        _carbonate_pkg="git+https://github.com/graphite-project/carbonate.git@master#egg=carbonate"
    else
        _carbonate_pkg="carbonate==$CARBONATE_VERSION"
    fi
    pip install \
        --install-option="--prefix=/usr/share/graphite" \
        --install-option="--install-lib=/usr/lib/python2.7/site-packages" \
        --install-option="--install-data=/var/lib/graphite" \
        --install-option="--install-scripts=/usr/bin" \
        "${_carbonate_pkg}"
}

require_build_arg() {
    ARG_NAME="$1"
    eval ARG_VALUE=\$$ARG_NAME

    if [ -z "$ARG_VALUE" ]; then
        echo "Missing build arg: $ARG_NAME"
        exit 1
    fi
}

# check build args
case "$IMAGE_TYPE" in
    carbon-c-relay)
        require_build_arg CARBON_C_RELAY_VERSION
        install=install_carbon_c_relay
        ;;
    go-carbon)
        require_build_arg GO_CARBON_VERSION
        install=install_go_carbon
        ;;
    carbonapi)
        require_build_arg CARBONAPI_VERSION
        install=install_carbonapi
        ;;
    grafana)
        require_build_arg GRAFANA_VERSION
        install=install_grafana
        ;;
    tools)
        require_build_arg WHISPER_VERSION
        require_build_arg CARBONATE_VERSION
        install=install_tools
        ;;
    *)
        echo "Unknown image type: $IMAGE_TYPE"
        exit 1
        ;;
esac

echo "$IMAGE_TYPE" > /image-type

setup_runtime_env
setup_build_env
$install
cleanup_build_env
