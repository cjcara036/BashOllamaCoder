# Ollama Project Assistant

A powerful, drop-in AI coding assistant for Linux terminals that brings the functionality of the HTML Mini Ollama Coder to your command line. This single bash script provides intelligent project-aware assistance for any codebase.

![Linux Terminal](https://img.shields.io/badge/Linux-Terminal-green) ![Bash Script](https://img.shields.io/badge/Bash-4.0+-blue) ![License](https://img.shields.io/badge/License-MIT-orange) ![Version](https://img.shields.io/badge/Version-1.0-red)

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [User Interface](#user-interface)
5. [Commands](#commands)
6. [Project Integration](#project-integration)
7. [Configuration](#configuration)
8. [Advanced Features](#advanced-features)
9. [Troubleshooting](#troubleshooting)
10. [Examples](#examples)

## Overview

The Ollama Project Assistant is a self-contained bash script that provides AI-powered coding assistance directly in your terminal. Unlike the web version, this tool:

- **Project-Aware**: Automatically detects your project type and structure
- **File Integrated**: Read, edit, and manage project files directly
- **Context Intelligent**: Maintains conversation history and project context
- **Terminal Native**: Beautiful, responsive terminal interface
- **Zero Dependencies**: Only requires standard Unix tools and curl

### Key Features

- 🤖 **AI Chat**: Natural conversation with Ollama models
- 📁 **Project Scanning**: Automatic project type detection and file indexing
- 🌿 **Git Integration**: Built-in git commands and status tracking
- 📝 **File Operations**: Read, edit, and create files with AI assistance
- 💾 **Session Management**: Save and load conversation history
- 🎨 **Rich UI**: Colored interface with real-time updates
- ⚙️ **Configurable**: Customizable themes, models, and settings

## Installation

### Prerequisites

- **Bash** (version 4.0 or higher)
- **curl** (for API communication)
- **Ollama** running locally or accessible via network
- **Standard Unix tools** (find, grep, sed, awk, etc.)

### Download and Setup

1. **Download the script**:
   ```bash
   # Download to your project directory
   wget https://raw.githubusercontent.com/cjcara036/ollama-assistant.sh
   # or using curl
   curl -O https://raw.githubusercontent.com/cjcara036/ollama-assistant.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x ollama-assistant.sh
   ```

3. **Run it**:
   ```bash
   ./ollama-assistant.sh
   ```

### System-wide Installation (Optional)

For convenience, you can install it system-wide:

```bash
# Move to a directory in your PATH
sudo mv ollama-assistant.sh /usr/local/bin/ollama-assistant

# Now you can run it from anywhere
ollama-assistant
```

## Quick Start

### First Run

1. **Navigate to your project directory**:
   ```bash
   cd /path/to/your/project
   ./ollama-assistant.sh
   ```

2. **Initial Setup**: The script will automatically:
   - Detect your project type (Node.js, Python, Rust, etc.)
   - Scan your project files
   - Test connection to Ollama
   - Create configuration files in `.ollama/` directory

3. **Start chatting**: Simply type your questions or requests!

### Basic Usage Example

```bash
$ ./ollama-assistant.sh

🤖 Welcome to Ollama Project Assistant!
Project: my-app (nodejs)
Files found: 24
Model: llama3.2 | Server: http://localhost:11434

Ready to help! Type your question or /help for commands

> How do I add authentication to my Express app?
```

## User Interface

### Terminal Layout

```
┌─ Ollama Project Assistant v1.0 ──────────────────────────────────┐
│ 📁 my-project │ 🤖 llama3.2 │ 🟢 Connected │ 💾 1.2k tokens    │
├─ Project Context ──────────────────── Chat ────────────────────┤
│ 🏷️  Node.js Project (Express, React)     │ 🧑 How do I add     │
│ 📋 src/server.js, src/client/           │    authentication? │
│ 📊 24 files, 1.8k LOC                   │                     │
│ 🌿 Git: clean, branch: main             │ 🤖 I'll help you    │
│ 📅 Last modified: src/auth.js (5m)      │    add JWT auth... │
│                                           │    💻 [javascript] │
│ 📎 Quick Actions:                        │    const jwt = ...  │
│ [F1]Help [F2]Files [F3]Git [F4]Config   │                     │
├─ Input ─────────────────────────────────────────────────────────┤
│> Type your question or command (/help for commands)            │
└──────────────────────────────────────────────────────────────────┘
```

### Interface Elements

- **Header Bar**: Shows project name, model, connection status, and token count
- **Project Context Panel**: Displays project type, key files, git status, and recent activity
- **Chat Area**: Shows conversation history with the AI
- **Input Prompt**: Where you type questions and commands
- **Quick Actions**: Keyboard shortcuts for common functions

### Color Scheme

The script supports both light and dark themes:

- 🟢 **Green**: User messages and success indicators
- 🔵 **Blue**: System messages and information
- 🟡 **Yellow**: Warnings and file operations
- 🔴 **Red**: Errors and problems
- ⚪ **White/Cyan**: AI responses and highlights

## Commands

### Chat Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/help` | Show help message | `/help` |
| `/files [pattern]` | List project files | `/files *.js` |
| `/read <file>` | Read file content | `/read package.json` |
| `/edit <file>` | Edit file with AI assistance | `/edit src/server.js` |
| `/git <command>` | Execute git command | `/git status` |

### Session Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/clear` | Clear chat history | `/clear` |
| `/save` | Save conversation | `/save` |
| `/load` | Load previous conversation | `/load` |
| `/config` | Configure settings | `/config` |
| `/exit` or `/quit` | Exit assistant | `/exit` |

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `F1` | Show help |
| `F2` | List files |
| `F3` | Git status |
| `F4` | Configuration |
| `Tab` | Command completion (planned) |
| `↑/↓` | Navigate command history (planned) |
| `Ctrl+C` | Graceful interrupt |

## Project Integration

### Supported Project Types

The assistant automatically detects and provides specialized help for:

| Type | Detection Files | Languages |
|------|----------------|-----------|
| **Node.js** | `package.json` | JavaScript, TypeScript |
| **Python** | `requirements.txt`, `pyproject.toml`, `setup.py` | Python |
| **Rust** | `Cargo.toml` | Rust |
| **Go** | `go.mod` | Go |
| **Java** | `pom.xml`, `build.gradle` | Java |
| **PHP** | `composer.json` | PHP |
| **Ruby** | `Gemfile` | Ruby |
| **C/C++** | `CMakeLists.txt`, `Makefile` | C, C++ |
| **General** | Any directory | Multiple |

### Context Awareness

The assistant automatically provides context including:

- **Project Structure**: File tree and key files
- **Dependencies**: Package managers and dependencies
- **Git Status**: Current branch, modified files, commit history
- **Recent Activity**: Recently modified files
- **File Relationships**: Imports, includes, and references

### File Operations

#### Reading Files
```bash
> /read package.json

--- package.json ---
{
  "name": "my-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0"
  }
}
--- End of package.json ---
```

#### Editing Files
```bash
> /edit src/server.js
# Current content displayed...
What changes would you like to make to src/server.js?
> Add authentication middleware
🤖  Getting AI assistance for editing...
✓ File src/server.js has been updated
Backup saved as src/server.js.backup.1699123456
```

## Configuration

### Settings Menu

Access the configuration menu with `/config`:

```
Configuration Menu
1. Ollama Server: http://localhost:11434
2. Model: llama3.2
3. Theme: dark
4. Auto-save: true
5. Git Integration: true
6. Back to chat

Enter option number to change (or 6 to exit):
```

### Configuration Options

| Setting | Default | Description |
|---------|---------|-------------|
| **Ollama Server** | `http://localhost:11434` | URL of your Ollama instance |
| **Model** | `llama3.2` | Default AI model to use |
| **Theme** | `dark` | Terminal color theme (`light`/`dark`) |
| **Auto-save** | `true` | Automatically save chat history |
| **Git Integration** | `true` | Enable git commands and status |

### Configuration File

Settings are stored in `.ollama/config.txt`:

```bash
OLLAMA_SERVER=http://localhost:11434
MODEL=llama3.2
THEME=dark
AUTO_SAVE=true
GIT_INTEGRATION=true
```

### Model Selection

To see available models:
```bash
> /config
> 2
Available models:
llama3.2
codellama
mistral
Enter model name:
> codellama
✓ Model updated
```

## Advanced Features

### Conversation Context

The assistant maintains conversation context across sessions:

- **Message History**: Stores your questions and AI responses
- **Project Context**: Includes file structure and git status
- **Session Persistence**: Resumes conversations where you left off
- **Context Window**: Intelligent management of context limits

### File Backups

When editing files, the assistant automatically creates backups:

```bash
# Original file: src/auth.js
# Backup created: src/auth.js.backup.1699123456
```

### Git Integration

Built-in git commands for seamless version control:

```bash
> /git status
Git command: git status
On branch main
Changes not staged for deployment:
  modified:   src/auth.js

> /git add src/auth.js
Git command: git add src/auth.js

> /git commit -m "Add authentication"
Git command: git commit -m "Add authentication"
```

### Session Management

Save and restore conversations:

```bash
> /save
✓ Chat saved to .ollama/chat_backup_20231104_143022.txt

> /load
Available chat backups:
-rw-r--r-- 1 user user 1234 Nov  4 14:30 .ollama/chat_backup_20231104_143022.txt
Enter backup filename to load (or press Enter to cancel):
> .ollama/chat_backup_20231104_143022.txt
✓ Chat loaded from .ollama/chat_backup_20231104_143022.txt
```

## Troubleshooting

### Common Issues

#### Connection Problems

**Error**: `Cannot connect to Ollama server`

**Solutions**:
1. Ensure Ollama is running:
   ```bash
   ollama serve
   ```

2. Check server URL in configuration:
   ```bash
   /config
   1
   # Verify server address
   ```

3. Test connection manually:
   ```bash
   curl http://localhost:11434/api/tags
   ```

#### Permission Issues

**Error**: `Permission denied` when reading files

**Solutions**:
1. Ensure script has proper permissions:
   ```bash
   chmod +x ollama-assistant.sh
   ```

2. Check file permissions:
   ```bash
   ls -la your-file.js
   ```

#### Terminal Issues

**Error**: Terminal display problems

**Solutions**:
1. Ensure terminal supports ANSI colors
2. Try different terminal emulators (gnome-terminal, iTerm2, etc.)
3. Check terminal size (minimum 80x24 recommended)

### Performance Tips

1. **Large Projects**: The assistant scans project files on startup. For very large projects (>1000 files), consider:
   ```bash
   # Limit file scanning
   find . -name "*.js" -not -path "./node_modules/*" | head -100
   ```

2. **Memory Usage**: Conversation history is kept in memory. Clear periodically:
   ```bash
   /clear
   ```

3. **Network Latency**: For remote Ollama servers, ensure stable connection:
   ```bash
   /config
   1
   # Update to faster server URL
   ```

### Debug Mode

Enable debug output by setting environment variable:

```bash
export OLLAMA_ASSISTANT_DEBUG=1
./ollama-assistant.sh
```

## Examples

### Example 1: Adding Authentication

```bash
> I'm building a Node.js Express app. How do I add JWT authentication?

🤖  I'll help you add JWT authentication to your Express app. Here's a complete implementation:

💻 [javascript]
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

// Middleware to verify JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.sendStatus(401);
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Login route
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  
  // Verify user credentials
  const user = await User.findOne({ username });
  if (!user || !await bcrypt.compare(password, user.password)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  // Generate JWT
  const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
  res.json({ token });
});

// Protected route
app.get('/protected', authenticateToken, (req, res) => {
  res.json({ message: 'Protected data', user: req.user });
});
```

### Example 2: Debugging Issues

```bash
> My React app is showing "Cannot read property 'map' of undefined" in the component list. Can you help me debug this?

🤖  This error typically occurs when you're trying to call `.map()` on an undefined array. Let me help you debug this. First, let's examine your components:

> /read src/components/ItemList.js

--- src/components/ItemList.js ---
import React from 'react';

const ItemList = ({ items }) => {
  return (
    <div>
      {items.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
    </div>
  );
};

export default ItemList;
--- End of src/components/ItemList.js ---

🤖  I can see the issue. Your `ItemList` component is trying to map over `items`, but the `items` prop might be undefined when the component first renders. Here's how to fix it:

💻 [javascript]
import React from 'react';

const ItemList = ({ items = [] }) => {  // Add default empty array
  return (
    <div>
      {items && items.length > 0 ? (  // Add defensive check
        items.map(item => (
          <div key={item.id}>{item.name}</div>
        ))
      ) : (
        <div>No items available</div>  // Add fallback
      )}
    </div>
  );
};

export default ItemList;
```

### Example 3: Refactoring Code

```bash
> This Python function is getting too long. Can you help me refactor it?

> /read src/data_processing.py

--- src/data_processing.py ---
def process_user_data(user_id, data, config, options):
    # Validate input
    if not user_id:
        raise ValueError("User ID required")
    if not data:
        raise ValueError("Data required")
    if not config:
        config = {}
    
    # Clean data
    cleaned_data = []
    for item in data:
        if item.get('active'):
            cleaned_item = {
                'id': item['id'],
                'name': item['name'].strip(),
                'email': item['email'].lower()
            }
            cleaned_data.append(cleaned_item)
    
    # Apply transformations
    transformed_data = []
    for item in cleaned_data:
        if config.get('uppercase_names'):
            item['name'] = item['name'].upper()
        if config.get('validate_emails'):
            if '@' not in item['email']:
                continue
        transformed_data.append(item)
    
    # Save results
    filename = f"user_{user_id}_processed.json"
    with open(filename, 'w') as f:
        json.dump(transformed_data, f)
    
    return transformed_data
--- End of src/data_processing.py ---

🤖  This function is indeed doing too many things. Let's refactor it into smaller, more focused functions:

💻 [python]
def validate_user_input(user_id, data, config):
    """Validate input parameters."""
    if not user_id:
        raise ValueError("User ID required")
    if not data:
        raise ValueError("Data required")
    return config or {}

def clean_data_items(data):
    """Clean and normalize data items."""
    cleaned_data = []
    for item in data:
        if item.get('active'):
            cleaned_item = {
                'id': item['id'],
                'name': item['name'].strip(),
                'email': item['email'].lower()
            }
            cleaned_data.append(cleaned_item)
    return cleaned_data

def apply_transformations(data, config):
    """Apply configured transformations to data."""
    transformed_data = []
    for item in data:
        if config.get('uppercase_names'):
            item['name'] = item['name'].upper()
        if config.get('validate_emails'):
            if '@' not in item['email']:
                continue
        transformed_data.append(item)
    return transformed_data

def save_processed_data(user_id, data):
    """Save processed data to file."""
    filename = f"user_{user_id}_processed.json"
    with open(filename, 'w') as f:
        json.dump(data, f)
    return filename

def process_user_data(user_id, data, config, options=None):
    """Process user data through the complete pipeline."""
    config = validate_user_input(user_id, data, config)
    cleaned_data = clean_data_items(data)
    transformed_data = apply_transformations(cleaned_data, config)
    save_processed_data(user_id, transformed_data)
    return transformed_data
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly**: `./ollama-assistant.sh`
5. **Submit a pull request**

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/your-repo/ollama-assistant/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-repo/ollama-assistant/discussions)
- **Email**: support@example.com

## Changelog

### Version 1.0.0
- Initial release
- Project-aware AI assistance
- File operations and git integration
- Rich terminal interface
- Session management
- Configuration system

---

**Happy Coding! 🚀**

Made with ❤️ by the Ollama Assistant Team

