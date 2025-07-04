# Start from the official WordPress FPM-Alpine image. This is the correct base.
FROM wordpress:fpm-alpine

# Switch to the root user to get permissions to install packages and extensions.
USER root

# Step 1: Install all system dependencies needed for PHP extensions.
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    unzip \
    zip \
    git \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    freetype-dev \
    imagemagick-dev \
    autoconf \
    g++ \
    make \
    pcre-dev

# Step 2: Configure and install the GD extension and other core extensions.
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-avif --with-freetype \
    && docker-php-ext-install -j$(nproc) gd mysqli opcache bcmath exif

# --- THIS IS THE NEW, RELIABLE METHOD ---
# Step 3: Compile and install the Redis extension from source.
RUN set -ex; \
    git clone https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis; \
    cd /usr/src/php/ext/redis; \
    git checkout -b 6.0.2 6.0.2; \
    docker-php-ext-install redis; \
    rm -rf /usr/src/php/ext/redis

# Step 4: Compile and install the Imagick extension from source.
RUN set -ex; \
    git clone https://github.com/Imagick/imagick.git /usr/src/php/ext/imagick; \
    cd /usr/src/php/ext/imagick; \
    git checkout -b 3.7.0 3.7.0; \
    docker-php-ext-install imagick; \
    rm -rf /usr/src/php/ext/imagick

# Step 5: Compile and install the Relay extension from source.
RUN set -ex; \
    git clone https://github.com/cachewerk/relay.git /usr/src/php/ext/relay; \
    cd /usr/src/php/ext/relay; \
    phpize; \
    ./configure; \
    make; \
    make install; \
    docker-php-ext-enable relay; \
    rm -rf /usr/src/php/ext/relay

# Step 6: Clean up. Remove the build tools to keep the final image small and secure.
RUN apk del autoconf g++ make pcre-dev imagemagick-dev libjpeg-turbo-dev libpng-dev libwebp-dev libavif-dev freetype-dev \
    && rm -rf /var/cache/apk/*

# Step 7: Copy your custom configuration files to apply your settings.
COPY conf/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY conf/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
COPY conf/www.conf /usr/local/etc/php-fpm.d/www-custom.conf

# Final Step: Switch back to the default, non-privileged user to run the application.
USER www-data
