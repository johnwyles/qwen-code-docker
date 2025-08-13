# Qwen Code Docker Environment

A containerized development environment for the qwen-code CLI tool with OpenAI-compatible API support and configurable Ollama endpoint integration.

## Quick Start

1. **Clone or navigate to this directory**
   ```bash
   cd /home/jwyles/code/qwen-code-docker
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your API key and configuration
   ```

3. **Test your configuration**
   ```bash
   node tests/test-connection.js
   ```

4. **Build and run the container**
   ```bash
   docker-compose up -d --build
   ```

5. **Access the interactive shell**
   ```bash
   docker-compose exec qwen-code bash
   ```

6. **Start using qwen-code**
   ```bash
   qwen-code --help
   ```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENAI_BASE_URL` | `https://avi.alliance.unm.edu:8443/v1` | OpenAI-compatible API endpoint |
| `OPENAI_API_KEY` | (required) | Your API key for authentication |
| `OLLAMA_HOST` | `avi.alliance.unm.edu:8443` | Ollama server endpoint |
| `OLLAMA_PROTOCOL` | `https` | Protocol to use (http/https) |
| `OLLAMA_API_KEY` | (required) | API key for Ollama authentication |
| `MODEL_NAME` | `qwen2.5-coder` | Model to use |
| `QWEN_MODEL` | `qwen2.5-coder:32b` | Legacy model setting |
| `CONTAINER_PORT` | `8080` | Port to expose from container |
| `WORKSPACE_PATH` | `./workspace` | Local workspace directory |

### Configuration Methods

#### Method 1: Environment File (.env)
```bash
# Copy the example file
cp .env.example .env

# Edit with your settings
nano .env
```

#### Method 2: Export Environment Variables
```bash
export OLLAMA_HOST=your-endpoint.com:8443
export OLLAMA_API_KEY=your_api_key
```

#### Method 3: Docker Compose Override
Create `docker-compose.override.yml`:
```yaml
version: '3.8'
services:
  qwen-code:
    environment:
      - OLLAMA_HOST=custom-endpoint.com:8443
      - OLLAMA_API_KEY=your_custom_key
```

### Platform-Specific Setup

#### Linux/macOS
```bash
# Standard setup
cd /home/jwyles/code/qwen-code-docker
cp .env.example .env
vim .env
node tests/test-connection.js
docker-compose up -d
```

#### Windows (PowerShell)
```powershell
# Clone and setup
cd qwen-code-docker
Copy-Item .env.example .env
notepad .env
node tests/test-connection.js
docker-compose up -d
```

### Custom Endpoint Configuration

#### University/Institution Endpoints
```bash
# UNM Alliance (default)
OLLAMA_HOST=avi.alliance.unm.edu:8443
OLLAMA_PROTOCOL=https

# Other institution example
OLLAMA_HOST=ml-server.university.edu:8443
OLLAMA_PROTOCOL=https
```

#### Local Ollama Instance
```bash
# Local installation
OLLAMA_HOST=localhost:11434
OLLAMA_PROTOCOL=http
OLLAMA_API_KEY=  # Leave empty for local instances
```

## Security Best Practices

### API Key Management
- **Never commit API keys to version control**
- Use `.env` files (included in `.gitignore`)
- Rotate API keys regularly
- Use different keys for development/production

### Environment Variables
```bash
# Good: Use .env file
echo "OLLAMA_API_KEY=secret123" >> .env

# Good: Export temporarily
export OLLAMA_API_KEY=secret123

# Bad: Don't put in shell history
# OLLAMA_API_KEY=secret123 docker-compose up
```

### File Permissions
```bash
# Secure your .env file
chmod 600 .env

# Secure any key files
chmod 600 config/api-keys/*
```

## Testing and Validation

### Connection Test
```bash
# Test your configuration
node tests/test-connection.js

# Full test including model functionality
node tests/test-connection.js --full

# Expected output:
# ✓ Environment variables loaded
# ✓ Connected to Ollama at avi.alliance.unm.edu:8443
# ✓ API key authentication successful
# ✓ Model qwen2.5-coder is available
```

### Manual Testing
```bash
# Test API endpoint directly
curl -H "Authorization: Bearer $OLLAMA_API_KEY" \
     https://avi.alliance.unm.edu:8443/api/tags

# Test model availability
curl -H "Authorization: Bearer $OLLAMA_API_KEY" \
     -X POST https://avi.alliance.unm.edu:8443/api/generate \
     -d '{"model":"qwen2.5-coder","prompt":"Hello"}'
```

### Settings Configuration

The `config/settings.json` file contains detailed configuration options for:
- API endpoint settings
- Model parameters
- Session management
- Interface preferences
- Development options
- Workspace configuration
- Security settings

## Volume Mounts

- `./workspace:/workspace/code` - Your code workspace
- `./config:/workspace/.config/qwen-code` - Configuration files
- `~/.gitconfig:/home/qwen/.gitconfig:ro` - Git configuration (read-only)
- `~/.ssh:/home/qwen/.ssh:ro` - SSH keys (read-only)

## Usage Examples

### Interactive Mode
```bash
docker-compose exec qwen-code bash
qwen-code
```

### Direct Command Execution
```bash
docker-compose exec qwen-code qwen-code generate --prompt "Create a hello world function"
```

### Code Review
```bash
docker-compose exec qwen-code qwen-code review /workspace/code/myfile.js
```

## File Structure

```
qwen-code-docker/
├── README.md               # This comprehensive guide
├── .env.example            # Environment variables template
├── .gitignore              # Git ignore rules for security
├── Dockerfile              # Container definition
├── docker-compose.yml      # Service orchestration
├── .dockerignore           # Docker ignore patterns
├── config/
│   └── settings.json       # qwen-code configuration
├── tests/
│   └── test-connection.js  # Connection validation script
└── workspace/              # Your code workspace
```

## Troubleshooting

### Connection Issues
```bash
# Check if endpoint is reachable
ping avi.alliance.unm.edu

# Test port connectivity
telnet avi.alliance.unm.edu 8443

# Check SSL certificate
openssl s_client -connect avi.alliance.unm.edu:8443
```

### Authentication Issues
- Verify API key is correct and not expired
- Check if API key has proper permissions
- Ensure API key is properly set in environment

### Model Issues
```bash
# List available models
curl -H "Authorization: Bearer $OLLAMA_API_KEY" \
     https://avi.alliance.unm.edu:8443/api/tags

# Pull model if needed
curl -H "Authorization: Bearer $OLLAMA_API_KEY" \
     -X POST https://avi.alliance.unm.edu:8443/api/pull \
     -d '{"name":"qwen2.5-coder"}'
```

### Common Error Messages

| Error | Solution |
|-------|----------|
| Connection refused | Check OLLAMA_HOST and port |
| Unauthorized | Verify OLLAMA_API_KEY |
| Model not found | Pull model or check MODEL_NAME |
| SSL certificate error | Check OLLAMA_PROTOCOL setting |

### Container Won't Start
- Check if all required environment variables are set
- Verify API endpoint is accessible
- Check Docker logs: `docker-compose logs -f qwen-code`

### Permission Issues
- The container runs as user `qwen` (non-root)
- Ensure workspace directory has proper permissions

### API Connection Issues
- Verify `OPENAI_BASE_URL` is correct
- Check if API key is valid
- Ensure network connectivity to the API endpoint

## Development

### Rebuilding the Container
```bash
docker-compose down
docker-compose up --build
```

### Updating qwen-code CLI
```bash
docker-compose exec qwen-code npm update -g qwen-code
```

### Accessing Logs
```bash
docker-compose logs -f qwen-code
```