FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y snmp bash && \
    rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy script
COPY main.sh /app/main.sh

# Make executable
RUN chmod +x /app/main.sh

# Create log folder
RUN mkdir -p /app/logs

# Default command
CMD ["/app/main.sh"]