# Installation Guide

## Linux Setup (Primary Target)

This script is designed specifically for Linux terminal environments.

### Prerequisites
```bash
# Check bash version (requires 4.0+)
bash --version

# Install curl if not present
sudo apt install curl          # Ubuntu/Debian
sudo yum install curl          # CentOS/RHEL
sudo dnf install curl          # Fedora
```

### Installation
```bash
# Download to your project directory
curl -O https://raw.githubusercontent.com/cjcara036/ollama-assistant.sh

# Make executable
chmod +x ollama-assistant.sh

# Run from any project directory
./ollama-assistant.sh
```

### System-wide Installation
```bash
# Move to system PATH
sudo mv ollama-assistant.sh /usr/local/bin/ollama-assistant

# Now available from anywhere
ollama-assistant
```

## Other Platforms (Limited Support)

### macOS
```bash
# Download and run (same as Linux)
curl -O https://raw.githubusercontent.com/your-repo/ollama-assistant.sh
chmod +x ollama-assistant.sh
./ollama-assistant.sh
```

### Windows (WSL Required)
This script requires a Linux environment. On Windows, use WSL:

1. **Install WSL**: `wsl --install` (in PowerShell as Admin)
2. **Install Ubuntu** from Microsoft Store
3. **Use WSL**:
   ```bash
   # In WSL terminal
   cd /mnt/c/path/to/your/project
   ./ollama-assistant.sh
   ```

## Prerequisites

### Required
- **bash** (version 4.0+)
- **curl** (for API calls)
- **Standard Unix tools** (find, grep, sed, awk, etc.)

### Ollama Setup
1. **Install Ollama**: https://ollama.ai/download
2. **Start Ollama server**:
   ```bash
   ollama serve
   ```
3. **Pull a model**:
   ```bash
   ollama pull llama3.2
   ```

## Quick Test

After installation, test with:

```bash
# In bash environment
./ollama-assistant.sh

# Should show:
# 🤖 Welcome to Ollama Project Assistant!
# Project: your-project (project-type)
# Files found: X
# Model: llama3.2 | Server: http://localhost:11434
```

## Troubleshooting

### "bash: command not found"
- Install Git Bash, WSL, or MSYS2 (see Windows setup above)

### "curl: command not found"
- Install curl: 
  - Windows: `winget install curl` or use Git Bash
  - Linux: `sudo apt install curl` or `sudo yum install curl`

### "Permission denied"
- Make script executable: `chmod +x ollama-assistant.sh`

### "Cannot connect to Ollama server"
- Ensure Ollama is running: `ollama serve`
- Check server URL in config: `/config`
- Test connection: `curl http://localhost:11434/api/tags`

### Terminal display issues
- Use a proper terminal (Git Bash, WSL, not cmd.exe)
- Ensure terminal supports ANSI colors
- Minimum terminal size: 80x24 characters

