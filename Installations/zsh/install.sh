#!/bin/bash

# Script to install Zsh.

# Check for package manager and install zsh
if command -v apt &> /dev/null; then
  echo "Using apt to install zsh..."
  sudo apt update
  sudo apt install -y zsh
else
  echo "Package manager not found. Unable to install zsh."
  exit 1
fi

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
  echo "Zsh installation failed."
  exit 1
else
  echo "Zsh installed!"
fi