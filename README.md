# 🚀 Qwen-Code Docker

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> 🐳 A containerized development environment for the Qwen-Code CLI with OpenAI-compatible API support

## ✨ Features

- 🔧 **Pre-configured Environment** - Ready-to-use Docker container with latest Qwen-Code CLI
- 🌐 **OpenAI Compatible** - Works with any OpenAI-compatible API (Ollama, OpenAI, etc.)
- 🌉 **Gemini-OpenAI Bridge** - Transparent translation layer for Ollama compatibility
- 🔄 **Intelligent Container Management** - Automatic rebuild detection and state handling
- 📁 **Persistent Storage** - Your work and configuration persist across container restarts
- ⚡ **Latest Versions** - Always uses the latest Node.js, npm, and Qwen-Code CLI
- 🛡️ **Security First** - Non-root user execution with proper permissions

## 🏗️ Architecture

### With Gemini-OpenAI Bridge (Recommended for Ollama)
```
┌─────────────────┐    ┌──────────────────┐    ┌───────────────┐
│   Your Host     │    │ Docker Container │    │  AI Service   │
│                 │    │                  │    │               │
│  ./start.sh ────┼────┤ qwen-code CLI    │    │               │
│  ./workspace/   │    │ ↓ (Gemini fmt)   │    │               │
│  ./config/      │    │ 🌉 Bridge :8080  ├────┤ Ollama Server │
│                 │    │ ↓ (OpenAI fmt)   │    │ (port 11434)  │
│                 │    │ Node.js 22 LTS   │    │               │
└─────────────────┘    └──────────────────┘    └───────────────┘
```

### Direct Connection (OpenAI/Compatible APIs)
```
┌─────────────────┐    ┌──────────────────┐    ┌──────────────┐
│   Your Host     │    │ Docker Container │    │  AI Service  │
│                 │    │                  │    │              │
│  ./start.sh ────┼────┤  qwen-code CLI   ├────┤  OpenAI API  │
│  ./workspace/   │    │  Node.js 22 LTS  │    │   (direct)   │
│  ./config/      │    │  Latest npm      │    │              │
└─────────────────┘    └──────────────────┘    └──────────────┘
```

## 🚀 Quick Start

### Prerequisites

- 🐳 [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- 🤖 An OpenAI-compatible API endpoint (Ollama, OpenAI, etc.)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/qwen-code-docker.git
   cd qwen-code-docker
   ```

2. **Configure your environment:**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your API settings
   ```

3. **Start the environment:**
   ```bash
   chmod +x start.sh
   ./start.sh
   ```

4. **Choose "OpenAI" when prompted** and start coding! 🎉

## ⚙️ Configuration

### Environment Variables

Create a `.env` file with your API configuration:

```bash
# API endpoint for your AI service
OPENAI_BASE_URL=http://your-ollama-server:11434/v1

# Your API key (leave empty for local Ollama)
OPENAI_API_KEY=your-api-key-here

# Model name to use
OPENAI_MODEL=qwen3-coder:latest

# For Ollama servers (recommended):
USE_GEMINI_BRIDGE=true
BRIDGE_TARGET_URL=http://your-ollama-server:11434/v1
BRIDGE_PORT=8080
GEMINI_DEFAULT_AUTH_TYPE=openai
```

### Supported Providers

| Provider | Base URL | API Key Required | Bridge Required |
|----------|----------|------------------|-----------------|
| 🦙 **Local Ollama** | `http://localhost:11434/v1` | No | ✅ Recommended |
| 🌐 **Remote Ollama** | `http://your-server:11434/v1` | Optional | ✅ Recommended |
| 🧠 **OpenAI** | `https://api.openai.com/v1` | Yes | ❌ Direct |
| 🔗 **Custom API** | `https://your-api.com/v1` | Varies | ⚠️ Depends |

## 🎯 Usage

### Starting the Environment

The intelligent `start.sh` script handles everything automatically:

```bash
./start.sh
```

**What it does:**
- 🔍 Detects if container exists and its state
- 🔄 Rebuilds image if Dockerfile has changed  
- 💾 Preserves your workspace and configuration
- 🚀 Launches you directly into the Qwen-Code CLI

### Working with Files

Your project files are mounted and persistent:

```bash
# Host directory          → Container path
./workspace/             → /workspace/code/
./config/                → /workspace/.config/qwen-code/
```

### Common Commands

```bash
# Stop the environment
docker compose down

# View container logs
docker compose logs -f

# Manual container access
docker exec -it qwen-code bash

# Rebuild from scratch
docker compose build --no-cache
```

## 🌉 Gemini-OpenAI Bridge

The qwen-code CLI is based on Google's Gemini CLI and sends requests in a hybrid format that includes Gemini-specific fields. This can cause compatibility issues with pure OpenAI-compatible APIs like Ollama.

Our **Gemini-OpenAI Bridge** solves this by:

- 🔄 **Transparent Translation** - Converts Gemini format to clean OpenAI format
- 🛡️ **Token Limit Protection** - Caps excessive token requests (200k+ → 4k)
- 🧹 **Field Cleaning** - Removes incompatible Gemini-specific fields
- ⚡ **Zero Configuration** - Automatically starts when `USE_GEMINI_BRIDGE=true`

### When to Use the Bridge

**✅ Use Bridge:**
- 🦙 Ollama servers (local or remote)
- 🔧 APIs that expect pure OpenAI format
- ⚠️ Getting 400 errors with direct connection

**❌ Direct Connection:**
- 🧠 OpenAI official API
- 🔗 APIs that handle Gemini format

### Bridge Configuration

Add these to your `.env` file:

```bash
# Enable bridge
USE_GEMINI_BRIDGE=true

# Where the bridge forwards requests
BRIDGE_TARGET_URL=http://your-ollama-server:11434/v1

# Bridge listening port (default: 8080)
BRIDGE_PORT=8080

# Enable debug logging (optional)
BRIDGE_DEBUG=true
```

### Troubleshooting Bridge

```bash
# Check bridge health
curl http://localhost:8080/health

# View bridge logs
docker logs qwen-code | grep Bridge

# Test request translation
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3-coder:latest","messages":[{"role":"user","content":"test"}]}'
```

For detailed bridge documentation, see [`gemini-openai-bridge/README.md`](gemini-openai-bridge/README.md).

## 🛠️ Development

### Project Structure

```
qwen-code-docker/
├── 📁 workspace/           # Your code files (mounted)
├── 📁 config/              # Qwen-Code configuration (mounted)
├── 📁 docs/                # Documentation
├── 📁 gemini-openai-bridge/ # Bridge source code & tests
├── 📁 tests/               # Integration tests
├── 🐳 Dockerfile           # Container definition
├── 🐳 docker-compose.yml   # Service configuration
├── ⚙️ .env                 # Your API settings
├── ⚙️ .env.example         # Example configuration
├── 🚀 start.sh             # Intelligent startup script
├── 🧪 docker-entrypoint.sh # Container startup script
└── 📖 README.md            # This file
```

### Container Specifications

- **Base Image:** Ubuntu 22.04 LTS
- **Node.js:** v22 LTS (latest)
- **npm:** Latest version
- **User:** Non-root (`qwen`) for security
- **Ports:** No exposed ports (connects to external APIs)

## 🔧 Troubleshooting

### Common Issues

**🔴 Connection Error**
```bash
# Check your API endpoint is accessible
curl -v http://your-api-server/v1/models

# Verify environment variables
docker exec qwen-code env | grep OPENAI
```

**🔴 Permission Denied (Docker)**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in, or run:
newgrp docker
```

**🔴 Container Won't Start**
```bash
# Check Docker is running
docker info

# Rebuild from scratch
docker compose down
docker compose build --no-cache
```

### Getting Help

1. 📖 Check the [Configuration Guide](docs/CONFIGURATION.md)
2. 🐛 Review [Troubleshooting Guide](docs/TROUBLESHOOTING.md)  
3. 💬 Open an [issue](https://github.com/your-username/qwen-code-docker/issues)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. 🍴 Fork the repository
2. 🌿 Create a feature branch
3. 📝 Make your changes
4. ✅ Test thoroughly
5. 📤 Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Qwen-Code CLI](https://github.com/QwenLM/Qwen3-Coder) - The amazing AI coding assistant
- [Ollama](https://ollama.ai/) - Local AI model serving
- [Docker](https://www.docker.com/) - Containerization platform

---

<div align="center">

**⭐ Star this repository if it helped you!**

Made with ❤️ for the AI coding community

</div>