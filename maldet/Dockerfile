FROM alpine:3.19

# Install dependencies, including Perl for Maldet to run.
RUN apk add --no-cache bash wget tar inotify-tools perl

# Manually create directories the maldet installer expects.
RUN mkdir -p /usr/local/sbin

WORKDIR /usr/local/src

# Download, extract, and install Maldet
RUN wget --user-agent="Mozilla/5.0" http://www.rfxn.com/downloads/maldetect-current.tar.gz && \
    tar -xzf maldetect-current.tar.gz && \
    cd maldetect-* && \
    ./install.sh

# Copy our new, simplified scan script
COPY scan.sh /usr/local/bin/run.sh

# Fix line endings and make executable.
RUN sed -i 's/\r$//' /usr/local/bin/run.sh && \
    chmod +x /usr/local/bin/run.sh

CMD ["/usr/local/bin/run.sh"]
