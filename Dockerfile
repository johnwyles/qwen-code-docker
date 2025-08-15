# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=22

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Update npm to latest version
RUN npm install -g npm@latest

# Verify Node.js and npm installation
RUN node --version && npm --version

# Install qwen-code CLI
RUN npm install -g @qwen-code/qwen-code \
    && echo "=== Verifying qwen-code installation ===" \
    && npm list -g @qwen-code/qwen-code \
    && echo "=== Finding qwen binary ===" \
    && find / -name "qwen" -type f 2>/dev/null || true \
    && echo "=== Checking npm bin directory ===" \
    && npm bin -g \
    && ls -la $(npm bin -g) \
    && echo "=== Creating symlink if needed ===" \
    && ln -sf $(npm bin -g)/qwen /usr/local/bin/qwen 2>/dev/null || true \
    && echo "=== Final check ===" \
    && which qwen || echo "Still not in PATH"

# Copy bridge code
COPY gemini-openai-bridge /bridge
WORKDIR /bridge
RUN npm install

# Create a non-root user for better security
RUN useradd -m -s /bin/bash qwen

# Set working directory
WORKDIR /workspace

# Copy entrypoint script (before switching to non-root)
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create config directory
RUN mkdir -p /workspace/.config/qwen-code \
    && chown -R qwen:qwen /workspace \
    && chown -R qwen:qwen /bridge

# Switch to non-root user
USER qwen

# Set environment variables
ENV QWEN_CONFIG_PATH=/workspace/.config/qwen-code
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]