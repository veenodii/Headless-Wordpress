# Start from the official Ubuntu Squid image to ensure stability.
FROM ubuntu/squid

# Switch to the root user to get permissions to install software.
USER root

# Update package lists and install the 'netcat' utility.
# This lightweight tool is used for the new, more reliable health check.
# We also clean up the package cache to keep the image size down.
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Switch back to the default, non-privileged 'proxy' user to run the service.
USER proxy
