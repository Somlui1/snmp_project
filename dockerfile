# Use lightweight Linux image with snmp tools
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y snmp bash && \
    rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy the script into container
COPY main.sh /app/main.sh

# Make it executable
RUN chmod +x /app/main.sh

# Run the script by default
CMD ["/app/main.sh"]