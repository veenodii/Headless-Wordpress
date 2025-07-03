# Start from the official Ubuntu Squid image to ensure stability and support.
FROM ubuntu/squid

# Switch to the root user to get permissions to install software.
USER root

# Update the package lists and install the 'squidclient' utility.
# This utility is required for the health check to function correctly.
# We also clean up the package cache to keep the image size down.
RUN apt-get update && \
    apt-get install -y --no-install-recommends squidclient && \
    rm -rf /var/lib/apt/lists/*

# Switch back to the default, non-privileged 'proxy' user to run the service.
USER proxy
