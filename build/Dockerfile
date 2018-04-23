FROM php:7.0-apache

#####################################
###### define global vars here ######
#####################################
ENV WORDPRESS_VERSION 4.9.4
ENV WORDPRESS_SHA1 0e630bf940fd586b10e099cd9195b3e825fb194c
ENV WORDPRESS_DB_HOST 127.0.0.1:3306
ENV WORDPRESS_DB_USER root
ENV WORDPRESS_DB_PASSWORD password 
ENV WORDPRESS_DB_NAME wordpress
ENV WORDPRESS_AUTH_KEY oephohti9Eithah3Equiveegha4uox9n
ENV WORDPRESS_SECURE_AUTH_KEY Fuofoth9iefai7oox9choh9iegoFahsh
ENV WORDPRESS_LOGGED_IN_KEY ahy3eip3ahgei4Aeshiuk3aimahphu3a
ENV WORDPRESS_NONCE_KEY geemeipaitaequac9Thephoma3eeLoh3
ENV WORDPRESS_AUTH_SALT zie7ahc7eeYaza3ohcooHa7kei4aj4eR
ENV WORDPRESS_SECURE_AUTH_SALT een3Ahwee7aejae9AhquohquoePaezee
ENV WORDPRESS_LOGGED_IN_SALT aem3pu7rohz9shohmeKaisei3otha7oa
ENV WORDPRESS_NONCE_SALT Tu4eiwooch4hei3rahngoih9ofu3aesh
ENV MEMCACHED_HOST tcp://127.0.0.1:11211
#####################################

RUN set -ex; \
if [ -n "${MYSQL_PW_ARG}" ]; then export WORDPRESS_DB_PASSWORD=${MYSQL_PW_ARG};fi;

# install the PHP extensions we need
RUN set -ex; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libjpeg-dev \
    libpng-dev \
  ; \
  \
  docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
  docker-php-ext-install gd mysqli opcache; \
  apt-get install -y zlibc zlib1g zlib1g-dev libmemcached-dev; \
  /bin/bash -c "printf '\n' | pecl install -a memcached"; \
  \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark; \
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
    | awk '/=>/ { print $3 }' \
    | sort -u \
    | xargs -r dpkg-query -S \
    | cut -d: -f1 \
    | sort -u \
    | xargs -rt apt-mark manual; \
  \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini
  

RUN a2enmod rewrite expires

VOLUME /var/www/html

RUN set -ex; \
  curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
  echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
  tar -xzf wordpress.tar.gz -C /usr/src/; \
  rm wordpress.tar.gz; \
  chown -R www-data:www-data /usr/src/wordpress  

COPY build/docker-entrypoint.sh /usr/local/bin/

COPY sources/ /var/www/html/

RUN set -ex; \
  ls -la /var/www/html/;

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
