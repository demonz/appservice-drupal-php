./build.sh 1

# import variables
REGISTRY=demonz
NAME=appservice-drupal-php
VERSION=7.x-7.2


set -ex
docker push ${REGISTRY}/${NAME}:${VERSION}
