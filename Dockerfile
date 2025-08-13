# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=20

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

# Install Node.js 20+
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Verify Node.js and npm installation
RUN node --version && npm --version

# Install qwen-code CLI globally
RUN npm install -g qwen-code

# Create a non-root user for better security
RUN useradd -m -s /bin/bash qwen \
    && usermod -aG sudo qwen

# Set working directory
WORKDIR /workspace

# Change ownership of workspace to qwen user
RUN chown -R qwen:qwen /workspace

# Switch to non-root user
USER qwen

# Set environment variables for OpenAI-compatible configuration
ENV OPENAI_BASE_URL=https://avi.alliance.unm.edu:8443/v1
ENV OPENAI_API_KEY=""
ENV OLLAMA_HOST=avi.alliance.unm.edu
ENV OLLAMA_PORT=8443
ENV QWEN_CONFIG_PATH=/workspace/.config/qwen-code

# Create config directory
RUN mkdir -p /workspace/.config/qwen-code

# Set entrypoint for interactive use
ENTRYPOINT ["/bin/bash"]