FROM php:7.2-apache
MAINTAINER Matt Royce <open.source@vyygir.me>

RUN apt-get update && apt-get install -y \
    git \
    curl \
    php-curl \
    php-gd \
    php-mcrypt \
    php-memcache \
    php-pear

RUN docker-php-ext-install mysqli
RUN docker-php-ext-install mbstring

RUN apt-get -y autoremove && apt-get clean
RUN apt-get install -y php-apcu

RUN a2enmod rewrite
RUN a2enmod socache_shmcb || true

RUN rm -Rf /etc/apache2/sites-available/*.conf
COPY apache/default.conf /etc/apache2/sites-available/
COPY apache/default-ssl.conf /etc/apache2/sites-available/

RUN a2ensite default
RUN a2ensite default-ssl

RUN curl -sS https://getcomposer.org/installer | /usr/bin/php
RUN mv composer.phar /usr/local/bin/composer

RUN mkdir -p /var/www/project
RUN chown www-data:www-data -R /var/www/project

ADD . /var/www/project

EXPOSE 80
EXPOSE 443

COPY scripts/setup.sh /
RUN chmod +x /setup.sh
CMD ["/setup.sh"]

CMD ["/bin/rm", "-f", "/var/run/apache2/apache2.pid"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
