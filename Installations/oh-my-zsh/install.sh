#!/bin/bash

# Check if zsh is installed
if ! command -v zsh &> /dev/null
then
  echo "zsh could not be found. Installing zsh..."
  if [[ "$(uname -s)" == "Darwin" ]]; then # macOS
    brew install zsh
  elif [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then # Debian/Ubuntu
      sudo apt-get update
      sudo apt-get install -y zsh
    elif [[ -f /etc/redhat-release ]]; then # RedHat/CentOS/Fedora
      sudo yum install -y zsh
    elif [[ -f /etc/arch-release ]]; then # Arch Linux
      sudo pacman -S --noconfirm zsh
    else
      echo "Unsupported Linux distribution. Please install zsh manually."
      exit 1
    fi
  else
    echo "Unsupported operating system. Please install zsh manually."
    exit 1
  fi
fi

# Check if git is installed
if ! command -v git &> /dev/null
then
  echo "git could not be found. Installing git..."
  if [[ "$(uname -s)" == "Darwin" ]]; then # macOS
    brew install git
  elif [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then # Debian/Ubuntu
      sudo apt-get update
      sudo apt-get install -y git
    elif [[ -f /etc/redhat-release ]]; then # RedHat/CentOS/Fedora
      sudo yum install -y git
    elif [[ -f /etc/arch-release ]]; then # Arch Linux
      sudo pacman -S --noconfirm git
    else
      echo "Unsupported Linux distribution. Please install git manually."
      exit 1
    fi
  else
    echo "Unsupported operating system. Please install git manually."
    exit 1
  fi
fi

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Oh-my-zsh installed successfully!"