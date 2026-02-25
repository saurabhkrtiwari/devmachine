# End User Setup Guide for DevMachine

This guide will walk you through setting up DevMachine on your Ubuntu Linux system as an end user.

## 🚀 Quick Start

### Option 1: Automated Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/saurabhkrtiwari/devmachine.git

# Navigate to the directory
cd devmachine

# Run the automated installer
./install.sh
```

### Option 2: Manual Installation

If you prefer manual setup:

```bash
# 1. Clone the repository
git clone https://github.com/saurabhkrtiwari/devmachine.git
cd devmachine

# 2. Make scripts executable
chmod +x devmachine
chmod +x modules/*.sh
chmod +x ai/*.sh
chmod +x ai/providers/*.sh

# 3. Create configuration directory
mkdir -p ~/.config/devmachine

# 4. Copy configuration template
cp config/devmachine.conf.example ~/.config/devmachine/devmachine.conf

# 5. Install to PATH
mkdir -p ~/bin
ln -sf $(pwd)/devmachine ~/bin/devmachine

# 6. Update PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 🔧 Configuration

After installation, you need to configure your AI provider:

```bash
# Edit the configuration file
nano ~/.config/devmachine/devmachine.conf
```

Edit the file with your AI provider credentials:
```bash
# OpenAI Provider Configuration
AI_PROVIDER=openai
AI_API_KEY=your_openai_api_key_here
AI_MODEL=gpt-3.5-turbo

# Uncomment and configure if using Anthropic
# ANTHROPIC_API_KEY=your_anthropic_api_key_here
# ANTHROPIC_MODEL=claude-3-sonnet-20240229
```

### Getting API Keys

1. **OpenAI API Key**:
   - Go to https://platform.openai.com/api-keys
   - Create a new secret key
   - Add it to your configuration

2. **Anthropic API Key** (Optional):
   - Go to https://console.anthropic.com/
   - Create a new API key
   - Add it to your configuration

## 🧪 Verification

After installation, verify everything is working:

```bash
# Check version
devmachine --version

# List available modules
devmachine list

# Run system diagnostics
devmachine doctor

# Test configuration
devmachine config show
```

## 📋 Usage Examples

### Install Development Tools

```bash
# Install JDK 21 (requires sudo)
sudo devmachine add jdk 21

# Install LocalStack (Docker-based)
devmachine add localstack

# Check status of installed tools
devmachine status jdk
devmachine status localstack
```

### Generate New Modules with AI

```bash
# Create a new module using AI
devmachine ai "Create a Docker module"
devmachine ai "Create a kubectl module"
devmachine ai "Create a Terraform module"
```

### Remove Tools

```bash
# Remove a tool
sudo devmachine remove jdk
devmachine remove localstack
```

## 🔍 Troubleshooting

### Common Issues

1. **"Command not found: devmachine"**
   ```bash
   # Make sure you sourced your bashrc
   source ~/.bashrc

   # Or check the PATH
   echo $PATH | grep bin
   ```

2. **Permission denied errors**
   ```bash
   # Some operations require sudo
   sudo devmachine add jdk 21
   ```

3. **AI provider errors**
   ```bash
   # Check your configuration
   devmachine config show

   # Test the provider
   ~/.config/devmachine/ai/providers/openai.sh test
   ```

4. **Docker-related issues**
   ```bash
   # Install Docker if needed
   sudo apt update
   sudo apt install docker.io

   # Add user to docker group
   sudo usermod -aG docker $USER

   # Logout and back in to apply changes
   ```

### Getting Help

- Run system diagnostics: `devmachine doctor`
- Check logs: `tail -f ~/devmachine/logs/devmachine.log`
- View documentation: `cat ~/devmachine/README.md`
- Report issues: https://github.com/saurabhkrtiwari/devmachine/issues

## 📁 Directory Structure

After installation, DevMachine will be organized as:

```
~/.config/devmachine/          # Configuration files
└── devmachine.conf            # Your settings

~/devmachine/                  # DevMachine source code
├── devmachine                # Main CLI script
├── modules/                  # Tool modules
├── ai/                       # AI system
├── config/                   # Templates
├── logs/                     # Application logs
└── README.md                 # Documentation

~/bin/devmachine              # Symlink to the CLI
```

## 🔄 Updates

To update DevMachine to the latest version:

```bash
cd ~/devmachine
git pull
./install.sh  # This will update without reinstalling
```

## 🌟 Next Steps

1. **Install your first tool**:
   ```bash
   sudo devmachine add jdk 21
   ```

2. **Try AI module generation**:
   ```bash
   devmachine ai "Create a Python module"
   ```

3. **Join the community**:
   - Star the GitHub repository
   - Report bugs or request features
   - Contribute modules

## 📞 Support

- GitHub Issues: https://github.com/saurabhkrtiwari/devmachine/issues
- Documentation: https://github.com/saurabhkrtiwari/devmachine/blob/main/README.md
- Discussions: https://github.com/saurabhkrtiwari/devmachine/discussions

---

Happy coding with DevMachine! 🎉