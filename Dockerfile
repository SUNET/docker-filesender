FROM uazlibraries/debian-php-fpm:latest

ENV FILESENDER_V=2.1 SSP_V=1.15.0

RUN \
cd /opt && \
curl -kL https://github.com/filesender/filesender/archive/filesender-$FILESENDER_V.tar.gz | tar xz && \
mv filesender-filesender-$FILESENDER_V filesender && \
curl -L https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SSP_V}/simplesamlphp-${SSP_V}.tar.gz | tar xz && \
mv simplesamlphp-${SSP_V} simplesamlphp 
#Installing dependencies for S3 with composer
RUN apt-get install -y php-curl
RUN cd /opt/filesender/optional-dependencies/s3 
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN cd /opt/filesender/optional-dependencies/s3
RUN mv composer.phar /usr/local/bin/composer
RUN cp /opt/filesender/optional-dependencies/s3/composer.json /
RUN composer install

RUN cd /opt 
# Add filesender and simplesamlphp configuration to /opt/conf
ADD template /opt/template

# Ensure correct runtime permissions - php-fpm runs as www-data
RUN chown -R www-data.www-data /opt/*

# Add setup and startup config files to /
ADD docker/* /

VOLUME ["/opt/filesender", "/opt/simplesamlphp"]

CMD ["/entrypoint.sh"]
