// Package main provides a command-line tool to ensure a predefined list of Visual Studio Code extensions are installed.
// It reads the desired extensions from a file specified in the user's dotfiles directory,
// compares them against the currently installed extensions, and installs any missing ones using the VS Code CLI.
package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
)

// checkCommandExists checks if a given command is available in the system's PATH.
// It uses exec.LookPath to search for the command.
// Returns true if the command is found, false otherwise.
func checkCommandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

// readFileLines reads the content of a file line by line and returns a slice of strings.
// Each element in the slice represents a line from the file.
// Returns the slice of lines and an error if the file cannot be opened or read.
func readFileLines(filePath string) ([]string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, fmt.Errorf("failed to open file '%s': %w", filePath, err)
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		return lines, fmt.Errorf("failed to read file '%s': %w", filePath, err)
	}
	return lines, nil
}

// getInstalledVSExtensions retrieves a list of currently installed Visual Studio Code extensions.
// It executes the 'code --list-extensions' command and parses its output.
// Returns a slice of installed extension identifiers and an error if the command fails.
func getInstalledVSExtensions() ([]string, error) {
	cmd := exec.Command("code", "--list-extensions")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("error listing extensions: %w, output: %s", err, string(output))
	}
	installed := strings.Split(string(output), "\n")
	var trimmed []string
	for _, ext := range installed {
		trimmed = append(trimmed, strings.TrimSpace(ext))
	}
	return trimmed, nil
}

// main is the entry point of the application.
// It orchestrates the process of checking and installing VS Code extensions.
func main() {
	// Check if the 'code' command is available.
	if !checkCommandExists("code") {
		fmt.Println("VS Code command 'code' not found in PATH. Please ensure VS Code is installed and the 'code' command is accessible.")
		return
	}

	// Determine the path to the code extensions list file in the dotfiles directory.
	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Printf("Error getting home directory: %v\n", err)
		return
	}
	extensionsFile := filepath.Join(homeDir, "dotfiles", "vscode", "vscode_extensions")

	// Read the list of desired VS Code extensions from the file.
	codeExtensions, err := readFileLines(extensionsFile)
	if err != nil {
		fmt.Printf("Error reading code extensions file '%s': %v\n", extensionsFile, err)
		return
	}
	sort.Strings(codeExtensions) // Sort the desired extensions for consistent comparison.

	// Get the list of currently installed VS Code extensions.
	installedExtensions, err := getInstalledVSExtensions()
	if err != nil {
		fmt.Printf("Error getting installed VS Code extensions: %v\n", err)
		return
	}
	sort.Strings(installedExtensions) // Sort the installed extensions for consistent comparison.

	// Identify extensions that are in the desired list but not currently installed.
	var uninstalledExtensions []string
	installedMap := make(map[string]bool)
	for _, ext := range installedExtensions {
		installedMap[ext] = true
	}

	for _, ext := range codeExtensions {
		if !installedMap[ext] && ext != "" { // Ignore empty lines in the extensions file.
			uninstalledExtensions = append(uninstalledExtensions, ext)
		}
	}

	// Inform the user about the checking process.
	fmt.Print("Checking for uninstalled VSCode extensions...")

	// If all desired extensions are installed.
	if len(uninstalledExtensions) == 0 {
		fmt.Println("all good!")
	} else {
		// If there are uninstalled extensions.
		fmt.Printf("found %d.\n", len(uninstalledExtensions))

		// Install each uninstalled extension.
		for _, extension := range uninstalledExtensions {
			fmt.Printf("Installing %s...\n", extension)
			cmd := exec.Command("code", "--install-extension", extension)
			output, err := cmd.CombinedOutput()
			if err != nil {
				fmt.Printf("Error installing extension '%s': %v, output: %s\n", extension, err, string(output))
			}
		}
		// Inform the user that the process is complete.
		fmt.Println("Done!")
	}
}
