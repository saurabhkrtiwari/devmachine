#!/bin/bash

# DevMachine Setup Demo
# Shows the complete end-user setup process

set -euo pipefail

echo "🎬 DevMachine Setup Demo"
echo "========================"
echo ""
echo "This script demonstrates how an end user would set up DevMachine."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Step 1: Clone
echo -e "${BLUE}Step 1: Clone the repository${NC}"
echo "Command: git clone https://github.com/saurabhkrtiwari/devmachine.git"
echo ""
echo "(Simulating clone...)"
mkdir -p /tmp/devmachine-demo
cp -r . /tmp/devmachine-demo/
cd /tmp/devmachine-demo
echo -e "${GREEN}✓ Repository cloned${NC}"
echo ""

# Step 2: Run installer
echo -e "${BLUE}Step 2: Run the installer${NC}"
echo "Command: ./install.sh"
echo ""

# Check if we're on a system with required tools
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}⚠️  curl not found, but we'll continue with demo${NC}"
fi

# Create minimal install script for demo
cat > install_demo.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🚀 Running DevMachine installation..."
echo "===================================="

# Make scripts executable
chmod +x devmachine
chmod +x modules/*.sh
chmod +x ai/*.sh
chmod +x ai/providers/*.sh

# Create config directory
mkdir -p ~/.config/devmachine

# Copy config
cp config/devmachine.conf.example ~/.config/devmachine/devmachine.conf

# Create bin directory and symlink
mkdir -p ~/bin
ln -sf $(pwd)/devmachine ~/bin/devmachine

# Add to PATH if not present
if ! grep -q "export PATH=\"\$HOME/bin:\$PATH\"" ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo "Added to PATH in ~/.bashrc"
fi

echo ""
echo "✅ Installation complete!"
EOF

chmod +x install_demo.sh
./install_demo.sh
echo -e "${GREEN}✓ Installation completed${NC}"
echo ""

# Step 3: Verify
echo -e "${BLUE}Step 3: Verify installation${NC}"
echo "Command: devmachine --version"
echo ""
if command -v devmachine &> /dev/null; then
    version=$(devmachine --version 2>/dev/null | head -n1)
    echo -e "${GREEN}✓ DevMachine installed: $version${NC}"
else
    echo -e "${YELLOW}⚠️  devmachine not in PATH yet${NC}"
    echo "Run: source ~/.bashrc"
fi
echo ""

# Step 4: List modules
echo -e "${BLUE}Step 4: List available modules${NC}"
echo "Command: devmachine list"
echo ""
devmachine list 2>/dev/null || echo "(devmachine command not yet in PATH)"
echo ""

# Step 5: Show configuration
echo -e "${BLUE}Step 5: Show configuration${NC}"
echo "Command: devmachine config show"
echo ""
echo "Configuration file created at:"
echo "  ~/.config/devmachine/devmachine.conf"
echo ""
echo "You need to edit this file with your AI API key:"
echo "  nano ~/.config/devmachine/devmachine.conf"
echo ""

# Step 6: Demo AI provider setup
echo -e "${BLUE}Step 6: AI Provider Configuration${NC}"
echo "Edit the config file to add your OpenAI API key:"
echo ""
echo "File: ~/.config/devmachine/devmachine.conf"
echo "Edit these lines:"
echo ""
echo "AI_PROVIDER=openai"
echo "AI_API_KEY=your_api_key_here"
echo "AI_MODEL=gpt-3.5-turbo"
echo ""

# Step 7: Next steps
echo -e "${BLUE}Step 7: Ready to use!${NC}"
echo ""
echo "After configuring your AI provider, you can:"
echo ""
echo "1. Source your bashrc:"
echo "   source ~/.bashrc"
echo ""
echo "2. Install tools:"
echo "   sudo devmachine add jdk 21"
echo "   devmachine add localstack"
echo ""
echo "3. Generate modules with AI:"
echo "   devmachine ai \"Create a Docker module\""
echo ""
echo "4. Run diagnostics:"
echo "   devmachine doctor"
echo ""

# Cleanup
cd /tmp
rm -rf devmachine-demo

echo -e "${GREEN}🎉 Demo complete!${NC}"
echo ""
echo "To install for real:"
echo "  git clone https://github.com/saurabhkrtiwari/devmachine.git"
echo "  cd devmachine"
echo "  ./install.sh"