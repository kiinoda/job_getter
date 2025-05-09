FROM alpine:3.19

# Install necessary packages
RUN apk add --no-cache \
    git \
    openssh-client \
    bash \
    curl \
    ca-certificates

# Set up directories for Lambda
RUN mkdir -p /var/task /var/runtime

# Set up Lambda environment variables
ENV LAMBDA_RUNTIME_DIR=/var/runtime \
    PATH="/var/runtime:${PATH}"

# Copy function code
COPY bootstrap /var/runtime/
COPY id_ed25519 /var/runtime/

# Set permissions
RUN chmod 755 /var/runtime/bootstrap && \
    chmod 666 /var/runtime/id_ed25519

# Set working directory
WORKDIR ${LAMBDA_RUNTIME_DIR}

# Set the entry point
ENTRYPOINT ["/var/runtime/bootstrap"]

