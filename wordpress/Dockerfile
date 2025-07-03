# --- Stage 1: Builder ---
# We use a temporary stage to compile our PHP extensions.
# We start with the same base image to ensure compatibility.
FROM wordpress:fpm-alpine AS builder

# Switch to the root user to install packages.
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

# Configure and install the GD extension.
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-avif --with-freetype \
    && docker-php-ext-install -j$(nproc) gd

# Install the Imagick and Redis extensions using PECL.
RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis

# Install other required PHP extensions, including OPcache.
RUN docker-php-ext-install -j$(nproc) mysqli opcache bcmath exif


# --- Stage 2: Final Production Image ---
# We start again from a clean base image.
FROM wordpress:fpm-alpine

# Set the working directory to the standard WordPress root.
# All subsequent RUN, COPY, and CMD commands will execute from this path.
WORKDIR /var/www/html

# Switch to root to copy files and set permissions.
USER root

# Copy the compiled PHP extensions from our temporary builder stage.
# This is the magic of multi-stage builds.
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

# Copy our custom configurations into the final image.
COPY conf/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY conf/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
COPY conf/www.conf /usr/local/etc/php-fpm.d/www-custom.conf

# Install WP-CLI for easier management.
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Ensure all configuration files have the correct ownership.
RUN chown www-data:www-data /usr/local/etc/php/conf.d/*

# Switch back to the default, non-privileged user to run the application.
USER www-data
