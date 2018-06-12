# Apache/PHP for Drupal Docker Container Image

* Base image: Docker official php:7.2.6-apache
* [Docker Hub](https://hub.docker.com/_/php)


## Build a this container locally for development and testing

    ./build.sh


## Upgrade the PHP version in use

This Dockerfile builds upon the official PHP repository maintained by Docker.

In order to upgrade the PHP version being used, increment the PHP_VERSION build argument

For available PHP versions, see https://hub.docker.com/r/library/php/tags/ 

