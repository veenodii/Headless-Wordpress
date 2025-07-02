FROM php:8.2-fpm-alpine3.21

USER root
# Install dependencies for PHP extensions and system tools
RUN apk add --no-cache \
    # System utils
    bash \
    curl \
    wget \
    unzip \
    # Runtime libraries for GD
    libjpeg-turbo \
    libpng \
    libwebp \
    libavif \
    freetype \
    imagemagick \
    # Build dependencies
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    freetype-dev \
    imagemagick-dev \
    # Build tools for PECL
    autoconf \
    g++ \
    make \
    pcre-dev

# Configure and install PHP extensions
# GD with JPEG, PNG, WebP, AVIF, and Freetype support
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-avif --with-freetype \
    && docker-php-ext-install -j$(nproc) gd

# Install other essential extensions
RUN docker-php-ext-install -j$(nproc) mysqli opcache bcmath exif

# Install imagick via PECL
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install redis via PECL
RUN pecl install redis \
    && docker-php-ext-enable redis

RUN docker-php-ext-install opcache
COPY conf/opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Clean up build dependencies and dev libraries to reduce image size
RUN apk del autoconf g++ make pcre-dev imagemagick-dev libjpeg-turbo-dev libpng-dev libwebp-dev libavif-dev freetype-dev && \
    rm -rf /var/cache/apk/*

RUN set -e; \
  curl -o /tmp/wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz" || { echo 'WordPress download failed'; exit 1; }; \
  tar -xzf /tmp/wordpress.tar.gz -C /usr/src/ || { echo 'WordPress extract failed'; exit 1; }; \
  rm /tmp/wordpress.tar.gz; \
  curl -o /tmp/redis-cache.zip -fSL "https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip" || { echo 'Redis plugin download failed'; exit 1; }; \
  unzip /tmp/redis-cache.zip -d /usr/src/wordpress/wp-content/plugins/ || { echo 'Redis plugin unzip failed'; exit 1; }; \
  rm /tmp/redis-cache.zip
# Copy our custom OPcache configuration

# Set up entrypoint to handle permissions and setup
COPY --from=wordpress:latest /usr/local/bin/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

USER www-data
# Expose the PHP-FPM port
EXPOSE 9000
CMD []