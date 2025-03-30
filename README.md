# My Dotfiles

This repository contains my personal configuration files (dotfiles) for various tools and applications, helping to maintain a consistent and efficient development environment.

## Prerequisites

Before setting up these dotfiles, you need to have Git installed on your Linux system.


### Step 1: Install Git on Debian GNU/Linux 12 (bookworm)

Open your terminal and run the following command to install Git using the `apt` package manager:

```bash
sudo apt update && sudo apt install git -y
```

After running the command, verify the installation by checking the Git version:

```bash
git --version
```
This should output the installed version of Git.


## First Time Use: Sign in to GitHub Using Commands (Browser Method)
To securely log in to your GitHub account for Git operations, the recommended method is using your web browser via the GitHub CLI. Follow these steps:


# Step 1: Install GitHub CLI (if not already installed)
If you haven't already installed the GitHub CLI, run the following command in your terminal:

```bash
sudo apt update && sudo apt install gh -y
```


# Step 2: Initiate the Login Process
Open your terminal and run the following command:

```bash
gh auth login
```


# Step 3: Select GitHub Account
You will be asked which GitHub account you want to log into:

```bash
? Which GitHub account do you want to log into?
  > GitHub.com
    GitHub Enterprise Server
```
Select `GitHub.com` by pressing Enter (unless you are connecting to a GitHub Enterprise Server).


# Step 4: Select Preferred protocal for git operations
You will be asked which protocal to use for git operations:

```bash
? What is your preferred protocol for Git operations?
  > HTTPS
    SSH
```
Select `HTTPS` by pressing Enter (unless you have good reasons to use SSH).


# Step 5: Authenticate Git using your github credentials
You will be asked to authenticate Git using your GitHub credentials:

```bash
? Authenticate Git with your GitHub credentials? (Y/n)
```
Type `Y` and press Enter to authenticate Git using your GitHub credentials.


# Step 6: Select Browser-Based Authentication
You will be prompted with the following options:

```bash
? What is your preferred way to authenticate GitHub CLI?
  > Login with a web browser
    Paste an authentication token
```
Select `Login with a web browser` by pressing Enter.


# Step 7: Confirm First-Time Use (if applicable)
If this is your first time using GitHub CLI, you might see:

```bash
? First time using GitHub CLI?
  > Yes
    No
```
Select `Yes` if this is your first time.


# Step 8: Authorize in Your Browser
Your default web browser will automatically open (or you will be provided with a link to open). On the GitHub website, you will be asked to authorize the "GitHub CLI" application. Click the "Authorize github" button.


# Step 9: Complete Login in Terminal
Once you have authorized the application in your browser, return to your terminal. The GitHub CLI will confirm that you are logged in successfully:

```bash
✓ Authentication complete. Press Enter to continue.
```
Press Enter in your terminal to finalize the login process.

You are now successfully logged in to GitHub using the CLI and your web browser! Git commands that require authentication will now be able to access your GitHub repositories.