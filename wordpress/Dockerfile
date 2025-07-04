# --- Stage 1: Builder ---
# We use a temporary "builder" stage to compile our PHP extensions.
FROM wordpress:fpm-alpine AS builder

# Switch to the root user to get permissions to install packages.
USER root

# Step 1: Install all system dependencies and build tools.
# We use the official $PHPIZE_DEPS variable for core build tools.
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    freetype-dev \
    imagemagick-dev

# Step 2: Configure and install the GD extension for image processing.
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-avif --with-freetype \
    && docker-php-ext-install -j$(nproc) gd

# Step 3: Install Imagick and PhpRedis using PECL.
RUN pecl install imagick && docker-php-ext-enable imagick
RUN pecl install redis && docker-php-ext-enable redis

# Step 4: Install other required PHP extensions, including OPcache.
RUN docker-php-ext-install -j$(nproc) mysqli opcache bcmath exif


# --- Stage 2: Final Production Image ---
# We start again from a clean base image.
FROM wordpress:fpm-alpine

# Set the working directory to the standard WordPress root.
WORKDIR /var/www/html

# Switch to root to copy files and set permissions.
USER root

# Copy the compiled PHP extensions from our temporary builder stage.
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

# This is more reliable than trying to copy generated files from the builder stage.
RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/docker-php-ext-imagick.ini \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini

# Install runtime dependencies and WP-CLI for management.
RUN apk add --no-cache mysql-client fcgi \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy ALL of your custom configuration files into the final image.
COPY conf/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY conf/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
COPY conf/www.conf /usr/local/etc/php-fpm.d/www-custom.conf

# Ensure all configuration files have the correct ownership.
RUN chown www-data:www-data /usr/local/etc/php/conf.d/* \
    && chown www-data:www-data /usr/local/etc/php-fpm.d/*

# Switch back to the default, non-privileged user to run the application.
USER www-data
