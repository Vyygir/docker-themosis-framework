FROM php:7.2-apache
MAINTAINER Matt Royce <open.source@vyygir.me>

RUN php -v
RUN apt search php

RUN which php

RUN apt-get update && apt-get install -y \
    git \
    curl

RUN docker-php-ext-install mysqli
RUN docker-php-ext-install mbstring

RUN apt-get -y autoremove && apt-get clean

RUN a2enmod rewrite
RUN a2enmod socache_shmcb || true

COPY apache/000-default.conf /etc/apache2/sites-available/
COPY apache/000-default-ssl.conf /etc/apache2/sites-available/

RUN a2ensite 000-default
RUN a2ensite 000-default-ssl

RUN curl -sS https://getcomposer.org/installer | /usr/local/bin/php
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
