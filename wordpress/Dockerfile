# --- Stage 1: Builder ---
# We use a temporary "builder" stage to compile our PHP extensions. This ensures
# that build tools like compilers are not included in the final production image.
FROM wordpress:fpm-alpine AS builder

# Switch to the root user to get permissions to install packages.
USER root

# Install all system dependencies and build tools needed to compile the extensions.
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

# Configure and install the GD extension for image processing.
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-avif --with-freetype \
    && docker-php-ext-install -j$(nproc) gd

# Install the Imagick, Redis, and Relay extensions using PECL.
# Relay depends on PhpRedis, and PECL handles this dependency.
RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis

# Install other required PHP extensions, including OPcache.
RUN docker-php-ext-install -j$(nproc) mysqli opcache bcmath exif


# --- Stage 2: Final Production Image ---
# We start again from a clean base image. This image contains the official
# WordPress files and a working PHP-FPM setup.
FROM wordpress:fpm-alpine

# Set the working directory to the standard WordPress root.
WORKDIR /var/www/html

# Switch to root to copy files and set permissions.
USER root

# Copy the compiled PHP extensions from our temporary builder stage.
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

# Install WP-CLI for easier management and other necessary runtime tools.
RUN apk add --no-cache mysql-client fcgi \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy ALL of your custom configuration files into the final image.
# This ensures all your settings for OPcache, uploads, and FPM are applied.
COPY conf/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY conf/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
COPY conf/www.conf /usr/local/etc/php-fpm.d/www-custom.conf

# Ensure all configuration files have the correct ownership.
RUN chown www-data:www-data /usr/local/etc/php/conf.d/*

# Switch back to the default, non-privileged user to run the application.
USER www-data
