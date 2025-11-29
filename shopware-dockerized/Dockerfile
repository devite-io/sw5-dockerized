FROM ubuntu:latest

ENV DB_PASSWORD=password
ENV VALKEY_PASSWORD=password

# install utilities
RUN apt update && apt install -y unzip git supervisor cron nano curl apache2

# install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt install -y nodejs

# prepare apache for rootless mode
RUN rm -rf /etc/apache2/sites-available /etc/apache2/sites-enabled /etc/apache2/conf-*/other-vhosts-access-log.conf /var/www/html/*
RUN mkdir -p /var/run/apache2
RUN chown -R www-data:www-data /var/cache/apache2 /var/www/html /etc/apache2 /var/run/apache2 \
    && chmod -R g+w /var/cache/apache2 /etc/apache2 /var/run/apache2

# install php
RUN apt install -y software-properties-common && add-apt-repository ppa:ondrej/php && apt update
RUN apt install -y php8.2 php8.2-fpm php8.2-curl php8.2-fileinfo php8.2-gd php8.2-iconv php8.2-intl php8.2-mbstring php8.2-pdo php8.2-pdo-mysql php8.2-simplexml php8.2-xml php8.2-zip php8.2-redis
RUN rm -rf /var/lib/apt/lists/*

# configure php-fpm
RUN sed -e 's/run\/php/tmp/' -i /etc/php/8.2/fpm/php-fpm.conf
COPY includes/config/www-pool.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY includes/config/php.ini /etc/php/8.2/fpm/php.ini
RUN touch /var/log/php8.2-fpm.log
RUN chown -R www-data:www-data /var/log/php8.2-fpm.log /etc/php/8.2/fpm

# install composer
WORKDIR /root
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

# set up cron job for scheduled tasks
COPY includes/cronjobs /etc/cron.d/sw-cronjobs
RUN chmod 0644 /etc/cron.d/sw-cronjobs \
    && crontab /etc/cron.d/sw-cronjobs \
    && touch /var/log/sw-cronjobs.log \
    && chown www-data:www-data /var/log/sw-cronjobs.log

# set up supervisor
COPY includes/config/supervisord.conf /etc/supervisor/supervisord.conf
RUN touch /var/log/supervisord.log && chown www-data:www-data /var/log/supervisord.log

# create entrypoint directory
RUN rm -rf /docker-entrypoint.d
RUN mkdir -p /docker-entrypoint.d && chown -R www-data:www-data /docker-entrypoint.d

# download Shopware
USER www-data
WORKDIR /var/www/html
RUN curl -L https://releases.shopware.com/install_5.7.18_f5172574955007876a6d9f53575ac624c69cbc3f.zip -o shopware.zip
RUN unzip shopware.zip && rm shopware.zip
RUN mkdir -p public

# copy Shopware overrides
COPY --chown=www-data:www-data --chmod=755 sw-overrides .
RUN sed -i "s/%db.password%/$DB_PASSWORD/g" config.default.php
RUN sed -i "s/%valkey.password%/$VALKEY_PASSWORD/g" config.default.php

# set up apache
USER root
COPY includes/config/apache2.conf /etc/apache2/apache2.conf
RUN usermod -d /var/www www-data \
    && chown www-data:www-data /var/www \
    && chmod 0777 /var/www
RUN a2enconf php8.2-fpm
RUN a2enmod proxy_fcgi rewrite headers expires

# add entrypoint scripts
COPY includes/scripts/entrypoint.sh /entrypoint.sh
RUN chmod -R +x /entrypoint.sh /docker-entrypoint.d

CMD ["sh", "/entrypoint.sh"]