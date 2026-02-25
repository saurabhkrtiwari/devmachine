# DevMachine - Production-Grade Dev Environment CLI Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.4+-blue.svg)](https://www.gnu.org/software/bash/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange.svg)](https://ubuntu.com/)

DevMachine is a modular, AI-powered CLI tool for setting up and managing development environments on Ubuntu Linux. Built with production-grade Bash, it provides a secure, idempotent, and extensible platform for automating developer tool installations.

## 🌟 Why This Project Exists

DevMachine addresses the fundamental challenges in managing development environments:

- **Inconsistent setups** across different machines and team members
- **Time-consuming manual installations** of development tools
- **Security risks** from unvetted installation scripts
- **Maintenance overhead** of keeping tools updated
- **Lack of standardization** in development environments

Our architectural goals:
- **Safety-first approach** with comprehensive validation and sandboxing
- **Modular design** that allows easy extension and customization
- **AI-powered automation** with strict safety controls
- **Production-quality code** suitable for enterprise use
- **Open-source transparency** for community trust and collaboration

## 🏗️ Architecture

```
devmachine/
├── devmachine                # Main CLI entry point
├── modules/                  # Tool modules (JDK, Maven, Docker, etc.)
├── ai/
│   ├── ai_engine.sh          # Core AI generation logic
│   ├── validator.sh          # Module validation
│   ├── sandbox.sh            # Safe execution testing
│   └── providers/            # Pluggable AI providers
│       └── openai.sh        # OpenAI provider example
├── config/
│   └── devmachine.conf       # Runtime configuration
├── tmp/                      # Temporary files
├── logs/                     # Application logs
├── README.md
├── LICENSE
└── .gitignore
```

### Core Principles

1. **CLI core must not depend on specific modules** - Dynamic discovery ensures flexibility
2. **Modules must not depend on other modules** - Clean separation of concerns
3. **AI providers must be fully pluggable** - Easy to add new AI services
4. **No hardcoded credentials** - Configuration-driven security
5. **No unsafe execution of AI output** - Multi-layered safety approach

## 🚀 Quick Start

### Prerequisites

- Ubuntu 20.04 or later
- Bash 4.4+
- Docker (for modules that require it)
- curl or wget

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/devmachine.git
   cd devmachine
   ```

2. **Make executable**
   ```bash
   chmod +x devmachine
   ```

3. **Link globally**
   ```bash
   sudo ln -sf $(pwd)/devmachine /usr/local/bin/devmachine
   ```

4. **Configure AI provider**
   ```bash
   cp config/devmachine.conf ~/.devmachine.conf
   # Edit ~/.devmachine.conf with your API keys
   ```

5. **Run system check**
   ```bash
   devmachine doctor
   ```

### Basic Usage

```bash
# List available modules
devmachine list

# Install a module
devmachine add jdk 21

# Check module status
devmachine status jdk

# Remove a module
devmachine remove jdk

# Run system diagnostics
devmachine doctor

# Generate a new module using AI
devmachine ai "Create a kubectl module"

# Show configuration
devmachine config show
```

## 🔧 Module System

DevMachine uses a modular architecture where each tool is implemented as a standalone Bash module.

### Module Requirements

Each module must implement three core functions:

```bash
# Install the tool
install() {
    # Implementation here
}

# Remove the tool
remove() {
    # Implementation here
}

# Check tool status
status() {
    # Implementation here
}
```

### Safety Features

- **Idempotent operations** - Safe to re-run
- **User confirmation** - Interactive approval for destructive actions
- **Path management** - Prevents duplicate PATH entries
- **Clean uninstall** - Complete removal of all artifacts
- **Configuration isolation** - Tool-specific settings in /etc/profile.d

### Core Modules

| Module | Versions | Status |
|--------|----------|--------|
| JDK | 17, 21, 25 | ✅ Production |
| LocalStack | Latest | ✅ Production |
| Maven | Latest | 🚧 WIP |
| Gradle | Latest | 🚧 WIP |
| Node.js | LTS | 🚧 WIP |
| IntelliJ IDEA | Latest | 🚧 WIP |
| VSCode | Latest | 🚧 WIP |
| DBeaver | Latest | 🚧 WIP |

## 🤖 AI System

DevMachine's AI system enables automatic module generation while maintaining strict safety controls.

### AI Flow

1. **Generate** - AI creates module code based on natural language prompts
2. **Validate** - Comprehensive checks for:
   - Required functions (install, remove, status)
   - Bash syntax correctness
   - Dangerous patterns (rm -rf /, mkfs, etc.)
   - Security vulnerabilities
3. **Sandbox Test** - Execute functions in isolated environment:
   - Mock dangerous commands
   - Dry-run mode for safety
   - Behavior validation
4. **Deploy** - Only after passing all checks:
   - Move to modules/ directory
   - Make executable
   - Add to CLI discovery

### Provider Configuration

```bash
# OpenAI Provider
AI_PROVIDER=openai
AI_API_KEY=your_key
AI_MODEL=gpt-3.5-turbo

# Anthropic Provider (example)
AI_PROVIDER=anthropic
ANTHROPIC_API_KEY=your_key
ANTHROPIC_MODEL=claude-3-sonnet-20240229
```

### Safety Features

- **Pattern matching** against known dangerous commands
- **Execution sandboxing** with mock commands
- **Code syntax validation** before execution
- **Credential detection** with manual review alerts
- **Fail-safe design** - blocks by default, allows only explicitly safe operations

## 🛡️ Security & Safety

### Design Principles

1. **Defense in depth** - Multiple layers of security controls
2. **Zero trust** - Never trust AI-generated code without validation
3. **Principle of least privilege** - Minimal required permissions
4. **Transparency** - All actions logged and auditable
5. **Isolation** - Sandboxed execution environments

### Security Features

- No API keys hardcoded in the codebase
- Configuration files excluded from version control
- Module validation before execution
- Command interception in sandbox
- Audit logging for all operations
- Regular security updates and vulnerability patches

## 📋 Roadmap

### Phase 1 (Current)
- [x] Core CLI framework
- [x] Module system
- [x] AI engine with validation
- [x] Basic modules (JDK, LocalStack)
- [x] Provider system

### Phase 2
- [ ] YAML configuration profiles
- [ ] Module dependency graph
- [ ] Versioned modules
- [ ] Additional AI providers
- [ ] CI/CD integration

### Phase 3
- [ ] Multi-platform support (macOS, Windows WSL)
- [ ] GUI interface
- [ ] Cloud deployment options
- [ ] Enterprise features (RBAC, audit logs)
- [ ] Marketplace for community modules

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Standards

- Follow Bash best practices
- Use shellcheck for linting
- Include error handling
- Add appropriate logging
- Write clear, maintainable code

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [GitHub Repository](https://github.com/yourusername/devmachine)
- [Documentation](https://devmachine.readthedocs.io)
- [Issues](https://github.com/yourusername/devmachine/issues)
- [Discussions](https://github.com/yourusername/devmachine/discussions)

## 🙏 Acknowledgments

- The open-source community for inspiration and feedback
- Bash maintainers for creating such a powerful scripting environment
- AI providers for enabling innovative development tools

---

**Built with ❤️ for the developer community**