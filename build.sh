#!/usr/bin/env bash
set -x -e


# import variables
REGISTRY=nbcwebcontainers.azurecr.io
NAME=appservice-drupal-php
VERSION=7.x-7.2


docker build \
  --build-arg PHP_VERSION=7.2.6 --build-arg DRUPAL_VERSION=7.59 --build-arg PHP_OPCACHE_ENABLE=0  \
  -t "${REGISTRY}/${NAME}:${VERSION}" -t "${REGISTRY}/${NAME}:latest" \
  .
