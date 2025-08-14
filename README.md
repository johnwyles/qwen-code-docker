# 🚀 Qwen-Code Docker

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> 🐳 A containerized development environment for the Qwen-Code CLI with OpenAI-compatible API support

## ✨ Features

- 🔧 **Pre-configured Environment** - Ready-to-use Docker container with latest Qwen-Code CLI
- 🌐 **OpenAI Compatible** - Works with any OpenAI-compatible API (Ollama, OpenAI, etc.)
- 🔄 **Intelligent Container Management** - Automatic rebuild detection and state handling
- 📁 **Persistent Storage** - Your work and configuration persist across container restarts
- ⚡ **Latest Versions** - Always uses the latest Node.js, npm, and Qwen-Code CLI
- 🛡️ **Security First** - Non-root user execution with proper permissions

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your Host     │    │  Docker Container │    │  AI Service     │
│                 │    │                  │    │                 │
│  ./start.sh ────┼────┤  qwen-code CLI   ├────┤  Ollama/OpenAI  │
│  ./workspace/   │    │  Node.js 22 LTS  │    │  (your choice)  │
│  ./config/      │    │  Latest npm      │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
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
```

### Supported Providers

| Provider | Base URL | API Key Required |
|----------|----------|------------------|
| 🦙 **Local Ollama** | `http://localhost:11434/v1` | No |
| 🌐 **Remote Ollama** | `http://your-server:11434/v1` | Optional |
| 🧠 **OpenAI** | `https://api.openai.com/v1` | Yes |
| 🔗 **Custom API** | `https://your-api.com/v1` | Varies |

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

## 🛠️ Development

### Project Structure

```
qwen-code-docker/
├── 📁 workspace/           # Your code files (mounted)
├── 📁 config/              # Qwen-Code configuration (mounted)
├── 📁 docs/                # Documentation
├── 🐳 Dockerfile           # Container definition
├── 🐳 docker-compose.yml   # Service configuration
├── ⚙️ .env                 # Your API settings
├── ⚙️ .env.example         # Example configuration
├── 🚀 start.sh             # Intelligent startup script
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