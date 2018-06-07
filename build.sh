#!/usr/bin/env bash
set -x -e


# import variables
REGISTRY=demonz
NAME=appservice-drupal-php
VERSION=7.x-7.2

PHP_VERSION=7.2.6
DRUPAL_VERSION=7.59
PHP_OPCACHE_ENABLE=${1:-0}

docker pull php:${PHP_VERSION}-apache


docker build \
  --build-arg PHP_VERSION=${PHP_VERSION} --build-arg DRUPAL_VERSION=${DRUPAL_VERSION} --build-arg PHP_OPCACHE_ENABLE=${PHP_OPCACHE_ENABLE}  \
  -t "${REGISTRY}/${NAME}:${VERSION}" -t "${REGISTRY}/${NAME}:latest" \
  .
