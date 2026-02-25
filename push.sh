#!/bin/bash

# DevMachine GitHub Push Script
# This script helps push DevMachine to GitHub

set -euo pipefail

echo "DevMachine - Push to GitHub"
echo "=========================="
echo ""

# Check if we're in the right directory
if [[ ! -f "devmachine" ]]; then
    echo "Error: devmachine file not found. Please run this script from the project root."
    exit 1
fi

# Check if remote is already configured
if ! git remote -v | grep -q origin; then
    echo "GitHub remote not configured."
    echo ""
    echo "Please follow these steps:"
    echo "1. Go to https://github.com/new"
    echo "2. Create a new repository named 'devmachine'"
    echo "3. Make it public"
    echo "4. Don't initialize with README"
    echo "5. Click 'Create repository'"
    echo ""
    echo "Then run one of these commands:"
    echo ""
    echo "HTTPS with token:"
    echo "git remote add origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/YOUR_USERNAME/devmachine.git"
    echo ""
    echo "SSH:"
    echo "git remote add origin git@github.com:YOUR_USERNAME/devmachine.git"
    echo ""
    echo "After adding the remote, run this script again."
    exit 1
fi

# Show current status
echo "Current git status:"
echo "------------------"
git status
echo ""

# Show remote
echo "Remote repository:"
git remote -v
echo ""

# Ask for confirmation
read -p "Ready to push to GitHub? (y/N): " confirm
if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Push to GitHub
echo "Pushing to GitHub..."
if git push -u origin main; then
    echo ""
    echo "✅ Success! DevMachine has been pushed to GitHub!"
    echo ""
    echo "Repository URL:"
    git remote get-url origin
    echo ""
    echo "Next steps:"
    echo "1. Visit your repository"
    echo "2. Share the link with others"
    echo "3. Consider adding badges to README.md"
    echo ""
else
    echo ""
    echo "❌ Push failed. Check your authentication and try again."
    echo ""
    echo "Troubleshooting:"
    echo "- Make sure you're logged into GitHub"
    echo "- Check your personal access token (if using HTTPS)"
    echo "- Verify SSH keys (if using SSH)"
fi