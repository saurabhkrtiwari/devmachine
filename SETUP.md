# DevMachine Setup Guide

This guide will help you set up DevMachine on your Ubuntu system.

## 🚀 Installation Steps

### 1. Prerequisites

Ensure you have the following installed:
- Ubuntu 20.04 or later
- Bash 4.4+
- curl (for downloading)
- wget (alternative to curl)
- Docker (for modules like LocalStack)

```bash
# Update package list
sudo apt update

# Install required packages
sudo apt install -y curl wget tar unzip

# Install Docker (if needed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 2. Download DevMachine

```bash
# Clone the repository
git clone https://github.com/yourusername/devmachine.git
cd devmachine

# Or download the release
curl -L -o devmachine.zip https://github.com/yourusername/devmachine/releases/latest/download/devmachine.zip
unzip devmachine.zip
cd devmachine
```

### 3. Make Executable

```bash
chmod +x devmachine
```

### 4. Link Globally

```bash
# Option 1: System-wide installation
sudo ln -sf $(pwd)/devmachine /usr/local/bin/devmachine

# Option 2: User-only installation (recommended)
mkdir -p ~/bin
ln -sf $(pwd)/devmachine ~/bin/devmachine
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 5. Configure AI Provider

```bash
# Copy configuration template
cp config/devmachine.conf.example ~/.devmachine.conf

# Edit the configuration
nano ~/.devmachine.conf
```

Edit the configuration file with your AI provider credentials:
```bash
AI_PROVIDER=openai
AI_API_KEY=your_actual_api_key_here
AI_MODEL=gpt-3.5-turbo
```

### 6. Run System Check

```bash
devmachine doctor
```

If everything is set up correctly, you should see:
```
[INFO] Running system diagnostics...
[SUCCESS] System check passed
```

## 🛠️ Basic Usage

### Verify Installation

```bash
devmachine --version
```

### List Available Modules

```bash
devmachine list
```

### Install Your First Module

```bash
# Install JDK 21 (requires sudo)
sudo devmachine add jdk 21
```

### Check Module Status

```bash
devmachine status jdk
```

### Generate a Module with AI

```bash
devmachine ai "Create a Docker module"
```

## 🔧 Advanced Configuration

### Custom Configuration Location

You can place the configuration file in multiple locations (in order of precedence):
1. `~/.devmachine.conf`
2. `/etc/devmachine.conf`
3. `./config/devmachine.conf` (in project directory)

### Logging

By default, logs are stored in `logs/devmachine.log`. You can adjust logging levels:
- `DEBUG` - Most verbose
- `INFO` - Default level
- `WARN` - Only warnings and errors
- `ERROR` - Only errors

### Environment Variables

You can override configuration with environment variables:
```bash
export AI_PROVIDER=openai
export AI_API_KEY=your_key
export LOG_LEVEL=DEBUG
```

## 🤖 Setting Up AI Providers

### OpenAI

1. Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Add to your configuration:
   ```bash
   AI_PROVIDER=openai
   AI_API_KEY=sk-your-key-here
   AI_MODEL=gpt-3.5-turbo  # or gpt-4
   ```

### Anthropic (Future)

1. Get an API key from [Anthropic Console](https://console.anthropic.com/)
2. Add to your configuration:
   ```bash
   AI_PROVIDER=anthropic
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   ANTHROPIC_MODEL=claude-3-sonnet-20240229
   ```

### Testing AI Connection

```bash
# Test the OpenAI provider
./ai/providers/openai.sh test
```

## 📁 Project Structure

```
devmachine/
├── devmachine                # Main CLI
├── modules/                  # Tool modules
│   ├── jdk.sh               # JDK module
│   └── localstack.sh        # LocalStack module
├── ai/                      # AI system
│   ├── ai_engine.sh         # Core AI logic
│   ├── validator.sh         # Module validator
│   ├── sandbox.sh           # Sandbox tester
│   └── providers/           # AI providers
│       └── openai.sh        # OpenAI provider
├── config/
│   ├── devmachine.conf      # Your config
│   └── devmachine.conf.example  # Template
├── tmp/                     # Temporary files
├── logs/                    # Application logs
├── README.md
├── LICENSE
├── .gitignore
└── SETUP.md                 # This file
```

## 🔍 Troubleshooting

### Common Issues

1. **Command not found: devmachine**
   - Make sure you've linked it to your PATH
   - Check with `which devmachine`
   - Restart your terminal session

2. **Permission denied when installing**
   - Use `sudo` for system-wide installations
   - Check write permissions on `/opt` and `/etc/profile.d`

3. **AI provider errors**
   - Verify API key is correct
   - Check network connectivity
   - Test with `./ai/providers/openai.sh test`

4. **Module validation fails**
   - Check module syntax with `bash -n module.sh`
   - Review dangerous patterns in validator logs

5. **Docker-related issues**
   - Ensure Docker is installed and running: `docker info`
   - Check user is in docker group: `groups`

### Getting Help

1. Check the logs: `tail -f logs/devmachine.log`
2. Run diagnostics: `devmachine doctor`
3. Check GitHub issues
4. Join our Discord community

## 🚀 Next Steps

1. **Explore modules**: Try installing different tools
   ```bash
   devmachine add localstack
   devmachine add maven
   ```

2. **Create custom modules**: Use AI to generate new modules
   ```bash
   devmachine ai "Create a Terraform module"
   ```

3. **Contribute**: Submit bug reports, feature requests, or code contributions

4. **Share**: Let others know about DevMachine!

## 📝 Notes

- Always review AI-generated modules before use
- Keep your API keys secure and never commit them
- Regularly update DevMachine for new features and security patches
- Backup your configuration before major updates

---

Happy coding with DevMachine! 🎉