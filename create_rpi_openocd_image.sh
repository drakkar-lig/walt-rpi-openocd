#!/bin/bash
eval "$(docker run waltplatform/dev-master env)"
THIS_DIR=$(cd $(dirname $0); pwd)
TMP_DIR=$(mktemp -d)
DOCKER_CACHE_PRESERVE_DIR=$THIS_DIR/.docker_cache

mkdir -p "$DOCKER_CACHE_PRESERVE_DIR"
cd $TMP_DIR

cp -ar $THIS_DIR/final-files files

cont_name=cont_$$
docker create --name $cont_name waltplatform/walt-node:rpi-openocd-builder
docker cp $cont_name:/tmp/openocd-build/openocd-bin.tar.gz .
docker rm $cont_name

cd files
tar xf ../openocd-bin.tar.gz
cd ..

docker-preserve-cache files $DOCKER_CACHE_PRESERVE_DIR

cat > Dockerfile << EOF
FROM $DOCKER_DEBIAN_RPI_IMAGE
MAINTAINER $DOCKER_IMAGE_MAINTAINER

RUN apt-get update && apt-get install -y libhidapi-hidraw0 gdb telnet
ADD files /
EOF

docker build --cpuset-cpus 0 -t "waltplatform/walt-node:rpi-openocd" .
result=$?

cd $THIS_DIR
rm -rf $TMP_DIR

exit $result

