#!/bin/bash
eval "$(docker run waltplatform/dev-master env)"
THIS_DIR=$(cd $(dirname $0); pwd)
TMP_DIR=$(mktemp -d)
DOCKER_CACHE_PRESERVE_DIR=$THIS_DIR/.docker_cache

mkdir -p "$DOCKER_CACHE_PRESERVE_DIR"
cd $TMP_DIR

cat > sources.list << EOF
deb $DEBIAN_RPI_REPO_URL $DEBIAN_RPI_REPO_VERSION $DEBIAN_RPI_REPO_SECTIONS
deb-src $DEBIAN_RPI_REPO_URL $DEBIAN_RPI_REPO_VERSION $DEBIAN_RPI_REPO_SECTIONS
EOF
docker-preserve-cache sources.list $DOCKER_CACHE_PRESERVE_DIR

cp -ar $THIS_DIR/openocd-build .

cat > Dockerfile << EOF
FROM $DOCKER_DEBIAN_RPI_IMAGE
MAINTAINER $DOCKER_IMAGE_MAINTAINER

ADD sources.list /etc/apt/sources.list
RUN apt-get update && apt-get build-dep -y openocd && apt-get install -y git
ADD openocd-build /tmp/openocd-build

WORKDIR /tmp/openocd-build
RUN ./bootstrap
RUN mkdir output && \
        ./configure --prefix=/tmp/openocd-build/output \
        --enable-verbose \
        --enable-bcm2835gpio \
        --enable-sysfsgpio \
        --enable-remote-bitbang
RUN make
RUN make install
RUN cd output && tar cfz ../openocd-bin.tar.gz .
EOF

docker build --cpuset-cpus 0 -t "waltplatform/walt-node:rpi-openocd-builder" .
result=$?

cd $THIS_DIR
rm -rf $TMP_DIR

exit $result

