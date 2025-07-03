# Start from the official Ubuntu Squid image to ensure stability.
FROM ubuntu/squid

# Switch to the root user to perform setup operations.
USER root

# Create the necessary log and cache directories for Squid.
# Then, set the ownership of these directories to the 'proxy' user,
# which is the user the Squid service runs as. This is a critical
# step to prevent permission-denied errors on startup.
RUN mkdir -p /var/log/squid /var/cache/squid /var/lib/squid /var/spool/squid && \
    chown -R proxy:proxy /var/log/squid /var/cache/squid /var/lib/squid /var/spool/squid

# Switch back to the default, non-privileged 'proxy' user to run the service.
USER proxy
