#!/bin/sh
set -e

usage() {
    echo "This image is used to compile openmetric components' binaries."
    echo "Currently, the following components are supported:"
    echo "    * carbon-c-relay: https://github.com/grobian/carbon-c-relay"
    echo "    * go-carbon: https://github.com/lomik/go-carbon"
    echo "    * carbonzipper: https://github.com/dgryski/carbonzipper"
    echo "    * carbonapi: https://github.com/dgryski/carbonapi"
    echo ""
    echo "Usage:"
    echo "docker run -it --rm -v \$PWD/binary:/binary openmetric/compile <component> <revision>"
    echo ""
    echo "Note:"
    echo "    * <revision> should be an existing git REV"
}

os() {
    if test -e /etc/alpine-release; then
        echo "alpine"
    elif test -e /etc/centos-release; then
        echo "centos"
    elif grep -q DISTRIB_ID=Ubuntu /etc/lsb-release; then
        echo "ubuntu"
    elif test -e /etc/debian_version; then
        echo "debian"
    else
        echo "linux"
    fi
}

# clones the $repo_url into $src_dir, check out $rev
clone_git_repo() {
    local repo_url=$1
    local src_dir=$2
    local rev=$3

    echo "Cloning repo: $repo_url, rev: $rev ..."
    mkdir -p $(dirname $src_dir)
    git clone -b $rev --depth 1 $repo_url $src_dir
}

# if the revision is a branch name, turn it into sha
get_git_rev() {
    local src_dir=$1
    local rev=$2
    (cd "$src_dir"; \
    if git show-ref --verify --quiet "refs/heads/$rev"; then
        git rev-parse --short HEAD
    else
        echo "$rev"
    fi)
}

compile_carbon_c_relay() {
    local repo_url=https://github.com/grobian/carbon-c-relay.git
    local src_dir=/build/carbon-c-relay
    local output=/binary/carbon-c-relay/carbon-c-relay
    local rev=${1:-master}

    echo "Compiling carbon-c-relay ..."

    clone_git_repo $repo_url $src_dir $rev
    rev=$(get_git_rev $src_dir $rev)

    (cd $src_dir && make relay)
    install -v -D -m 755 $src_dir/relay $output-$rev-$(os)
    ln -snf $(basename $output-$rev-$(os)) $output

    echo "Successfully compiled carbon-c-relay, output: $output-$rev-$(os)"
}

compile_go_carbon() {
    local repo_url=https://github.com/lomik/go-carbon.git
    local src_dir=/build/go-carbon
    local output=/binary/go-carbon/go-carbon
    local rev=${1:-master}

    echo "Compiling go-carbon..."

    clone_git_repo $repo_url $src_dir $rev
    rev=$(get_git_rev $src_dir $rev)

    (cd $src_dir && make submodules && make)
    install -v -D -m 755 $src_dir/go-carbon $output-$rev-$(os)
    ln -snf $(basename $output-$rev-$(os)) $output

    echo "Successfully compiled go-carbon, output: $output-$rev-$(os)"
}

compile_carbonzipper() {
    git config --global url.https://github.com/openmetric/carbonapi.insteadOf https://github.com/dgryski/carbonapi
    git config --global url.https://github.com/openmetric/carbonzipper.insteadOf https://github.com/dgryski/carbonzipper

    local repo_url=https://github.com/dgryski/carbonzipper.git
    local src_dir=$GOPATH/src/github.com/dgryski/carbonzipper
    local output=/binary/carbonzipper/carbonzipper
    local rev=${1:-master}

    echo "Compiling carbonzipper..."

    clone_git_repo $repo_url $src_dir $rev
    rev=$(get_git_rev $src_dir $rev)

    go get -v github.com/dgryski/carbonzipper
    install -v -D -m 755 $GOPATH/bin/carbonzipper $output-$rev-$(os)
    ln -snf $(basename $output-$rev-$(os)) $output

    echo "Successfully compiled carbonzipper, output $output-$rev-$(os)"
}

compile_carbonapi() {
    git config --global url.https://github.com/openmetric/carbonapi.insteadOf https://github.com/dgryski/carbonapi
    git config --global url.https://github.com/openmetric/carbonzipper.insteadOf https://github.com/dgryski/carbonzipper

    local repo_url=https://github.com/dgryski/carbonapi.git
    local src_dir=$GOPATH/src/github.com/dgryski/carbonapi
    local output=/binary/carbonapi/carbonapi
    local rev=${1:-master}

    echo "Compiling carbonapi..."

    clone_git_repo $repo_url $src_dir $rev
    rev=$(get_git_rev $src_dir $rev)

    go get -v github.com/dgryski/carbonapi
    install -v -D -m 755 $GOPATH/bin/carbonapi $output-$rev-$(os)
    ln -snf $(basename $output-$rev-$(os)) $output

    echo "Successfully compiled carbonapi, output $output-$rev-$(os)"
}

compile_grafana() {
    local repo_url=https://github.com/grafana/grafana.git
    local src_dir=$GOPATH/src/github.com/grafana/grafana
    local output=/binary/grafana/grafana
    local rev=${1:-master}

    echo "Compiling grafana-server..."

    clone_git_repo $repo_url $src_dir $rev
    rev=$(get_git_rev $src_dir $rev)

    cd $src_dir
    go run build.go setup
    go run build.go build

    npm install -g yarn
    yarn install --pure-lockfile
    # disable karma:test task
    sed -i "/karma:test/d" tasks/build_task.js
    ./node_modules/.bin/grunt release

    mkdir -p tarball-root/usr/bin tarball-root/etc/default tarball-root/usr/share/grafana
    cp tmp/bin/grafana-server tmp/bin/grafana-cli tarball-root/usr/bin
    cp packaging/deb/default/grafana-server tarball-root/etc/default
    cp -r tmp/conf tmp/public tmp/scripts tmp/vendor tarball-root/usr/share/grafana/
    mkdir -p $(dirname $output)
    tar -C tarball-root -czf $output-$rev-$(os).tar.gz .

    echo "Successfully compiled grafana, output $output-$rev-$(os).tar.gz"
}

case "$1" in
    carbon-c-relay)
        compile_carbon_c_relay $2
        ;;
    go-carbon)
        compile_go_carbon $2
        ;;
    carbonzipper)
        compile_carbonzipper $2
        ;;
    carbonapi)
        compile_carbonapi $2
        ;;
    grafana)
        compile_grafana $2
        ;;
    *)
        if command -v "$1" >/dev/null; then
            exec "$@"
        else
            usage
        fi
        ;;
esac
