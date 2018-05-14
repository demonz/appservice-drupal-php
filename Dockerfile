# see https://hub.docker.com/r/library/php/tags/ for available php versions
# modified from https://github.com/Azure-App-Service/php/blob/master/7.2.1-apache/Dockerfile
ARG PHP_VERSION

FROM php:${PHP_VERSION}-apache

MAINTAINER Demonz Media <hello@demonzmedia.com>

ARG PHP_VERSION
ARG DRUPAL_VERSION


# install the PHP extensions we need
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libpq-dev \
        libmcrypt-dev \
        libldap2-dev \
        libldb-dev \
        libicu-dev \
        libgmp-dev \
        libmagickwand-dev \
        \
        # ssh server for azure
        openssh-server vim curl wget tcptraceroute \
        \
        # image optimistaion tools
        jpegoptim pngquant optipng; \
    \
    # change root password to allow login via azure portal
    echo "root:Docker!" | chpasswd; \
    ln -s /usr/bin/jpegoptim /usr/local/bin/jpegoptim; \
    ln -s /usr/bin/pngquant /usr/local/bin/pngquant; \
    ln -s /usr/bin/optipng /usr/local/bin/optipng; \
    ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so; \
    ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so; \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h; \
    rm -rf /var/lib/apt/lists/*; \
    pecl install imagick-beta; \
    pecl install mcrypt-1.0.1; \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-install gd \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        ldap \
        intl \
        gmp \
        zip \
        bcmath \
        mbstring \
        pcntl; \
    docker-php-ext-enable imagick; \
    docker-php-ext-enable mcrypt; \
    \
    # add redis support !!!
    pecl install redis; \
    echo "extension=redis.so;" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini;


# download and install php uploadprogress
# see https://duntuk.com/how-install-pecl-uploadprogress
RUN set -ex; \
    # download
    url="https://github.com/Jan-E/uploadprogress/archive/master.tar.gz";  \
    wget -qO- "${url}" | tar xz -C /usr/local/src/; \
    # install
    cd /usr/local/src/uploadprogress-master; \
    phpize; \
    ./configure; \
    make; \
    make install; \
    \
    echo "extension=uploadprogress.so;" > /usr/local/etc/php/conf.d/docker-php-ext-uploadprogress.ini; \
    \
    # clean up
    rm -rf /usr/local/src/*;


# download a barebones drupal install
RUN set -ex; \
    # download
    url="https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz";  \
    wget -qO- "${url}" | tar xz -C /usr/local/src/; \
    rm -rf /var/www/html; \
    mv /usr/local/src/drupal-${DRUPAL_VERSION}/ /var/www/html; \
    cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.appservice.php; \
    \
    # clean up
    rm -rf /usr/local/src/*;


# ultimately install composer, drush, etc
#



COPY apache2.conf /bin/
COPY init_container.sh /bin/
COPY sshd_config /etc/ssh/

RUN a2enmod rewrite expires include deflate


RUN set -ex; \
   rm -f /var/log/apache2/*; \
   rmdir /var/lock/apache2; \
   rmdir /var/run/apache2; \
   rmdir /var/log/apache2; \
   chmod 777 /var/log; \
   chmod 777 /var/run; \
   chmod 777 /var/lock; \
   chmod 755 /bin/init_container.sh; \
   cp /bin/apache2.conf /etc/apache2/apache2.conf;


RUN { \
        echo "opcache.memory_consumption=128"; \
        echo "opcache.interned_strings_buffer=8"; \
        echo "opcache.max_accelerated_files=4000"; \
        echo "opcache.revalidate_freq=60"; \
        echo "opcache.fast_shutdown=1"; \
        echo "opcache.enable_cli=1"; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
        # php resource limits
        echo "max_execution_time=300"; \
        echo "max_input_vars=5000"; \
        echo "memory_limit=1024M"; \
        echo "upload_max_filesize=100M"; \
        \
        echo "error_log=/var/log/apache2/php-error.log"; \
        echo "log_errors=On"; \
        echo "display_errors=Off"; \
        echo "display_startup_errors=Off"; \
        echo "date.timezone=UTC"; \
    } > /usr/local/etc/php/conf.d/php.ini



EXPOSE 2222 8080

ENV PHP_VERSION="${PHP_VERSION}" \
    DRUPAL_VERSION="${DRUPAL_VERSION}" \
    APACHE_RUN_USER="www-data" \
    WEBSITES_PORT="8080" \
    WEBSITE_ROLE_INSTANCE_ID="localRoleInstance" \
    WEBSITE_INSTANCE_ID="localInstance" \
    PATH="${PATH}:/var/www/html"

WORKDIR /var/www/html

ENTRYPOINT ["/bin/init_container.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]