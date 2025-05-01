#!/bin/bash

# Script to print the content of a specific line number if it exists in a file,
# or "notfound" otherwise.

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_path> <line_number>"
    # Exit with a non-zero status for incorrect script usage.
    exit 1
fi

file_path="$1"
requested_line_num="$2"

# Check 1: File exists and is a regular file.
# If the file doesn't exist, the line cannot exist in it.
if [ ! -f "$file_path" ]; then
    echo "Current Open File Doesn't Exist"
    exit 0
fi


# Check 2: requested_line_num must be a positive integer (e.g., 1, 2, 3, ...).
# Line numbers are typically 1-indexed and positive.
# The regex ^[1-9][0-9]*$ checks for an integer starting with a non-zero digit.
requested_line_num=$((requested_line_num + 1))

# Run all tests since line was not selected in Current Open File.
if [[ "$requested_line_num" == 1 ]]; then 
    echo ".*"
    exit 0
fi


if ! [[ "$requested_line_num" =~ ^[1-9][0-9]*$ ]]; then
    echo "notfound"
    exit 0
fi

# Attempt to fetch the content of the specified line using sed.
# `sed -n "${line_number}p" "$file_path"` works as follows:
#   - If the line exists (even if it's an empty line), sed prints the line's content
#     (an empty line will result in a newline character being printed by sed's 'p' command).
#   - If the line number is out of bounds (e.g., greater than the total lines
#     in the file), sed prints nothing.
line_content=$(sed -n "${requested_line_num}p" "$file_path")



# Function to extract Go test name from a line of text
# Accepts one argument: the line content.
# Prints the test name if the line matches the pattern:
# func TestName(variableName *testing.T) {
# where 'variableName' can be any valid Go identifier.
# Otherwise, prints nothing and returns a non-zero status.
extract_test_name_from_line() {
  local line_content="$1"
  local test_name

  # Regex pattern to match the beginning of a Go test function signature
  # and capture the test name. The *testing.T variable name is now flexible.
  # Example line it matches: func TestMyFunction(customVar *testing.T) { // optional comment
  #
  # Breakdown of the updated regex:
  # ^                        - Anchors the match to the start of the line.
  # func                     - Matches the literal string "func " (note the space).
  # (Test[A-Za-z0-9_]+)     - This is Capture Group 1 (the test name):
  #                            - "Test" literal string.
  #                            - [A-Za-z0-9_]+ matches one or more alphanumeric characters or underscores.
  # \(                       - Matches a literal opening parenthesis.
  # [a-zA-Z_][a-zA-Z0-9_]* - Matches the variable name for *testing.T:
  #                            - Starts with a letter or underscore.
  #                            - Followed by zero or more letters, digits, or underscores.
  # \                        - Matches a literal space (between variable name and '*testing.T').
  # \*testing\.T             - Matches the literal string "*testing.T":
  #                            - \* matches a literal asterisk.
  #                            - \. matches a literal dot.
  # \)                       - Matches a literal closing parenthesis.
  # \ {                      - Matches a literal " {" (space followed by an opening curly brace).
  # The regex does not anchor to the end of the line ($), so it allows
  # for comments or other text after the opening brace.
  local regex_pattern="^func (Test[A-Za-z0-9_]+)\([a-zA-Z_][a-zA-Z0-9_]* \*testing\.T\) \{"

  if [[ "$line_content" =~ $regex_pattern ]]; then
    # BASH_REMATCH is an array variable holding the results of the regex match.
    # BASH_REMATCH[0] contains the entire string that matched the pattern.
    # BASH_REMATCH[1] contains the string matched by the first capture group (the test name).
    test_name="${BASH_REMATCH[1]}"
    echo "-run '$test_name'"
    return 0 # Success
  fi
  return 1 # No match found
}

# Function to extract Go test method name (defined on a receiver) from a line of text.
# Accepts one argument: the line content.
# Prints the test method name if the line matches the pattern:
# func (someVar *someType) TestName() {
# Otherwise, prints nothing and returns a non-zero status.
extract_method_test_name_from_line() {
  local line_content="$1"
  local test_name

  # Regex pattern to match Go method test signatures and capture the TestMethodName.
  # Example line it matches: func (s *mySuite) TestMyCase() { // optional comment
  #
  # Breakdown of the regex:
  # ^func                             - Anchors to the start of the line, matches "func ".
  # \(                                - Literal opening parenthesis for the receiver.
  # [a-zA-Z_][a-zA-Z0-9_]* - Matches the receiver variable name (e.g., t, s, suite).
  # \                                 - Literal space after the receiver variable name.
  # \* - Literal asterisk (pointer).
  # [a-zA-Z_][a-zA-Z0-9_]* - Matches the receiver type name (e.g., defaultMountCommonTest, mySuite).
  # \)                                - Literal closing parenthesis for the receiver.
  # \                                 - Literal space after the receiver part.
  # (Test[A-Za-z0-9_]+)             - This is CAPTURE GROUP 1: The test method name.
  #                                   - Must start with "Test".
  #                                   - Followed by one or more alphanumeric characters or underscores.
  # \(\)                              - Literal empty parentheses "()" for the method's arguments.
  # \                                 - Literal space before the opening brace.
  # \{                                - Literal opening brace "{".
  # The regex allows for content after the opening brace (e.g., comments).
  local regex_pattern="^func \([a-zA-Z_][a-zA-Z0-9_]* \*[a-zA-Z_][a-zA-Z0-9_]*\) (Test[A-Za-z0-9_]+)\(\) \{"

  if [[ "$line_content" =~ $regex_pattern ]]; then
    # BASH_REMATCH[0] is the entire string that matched the pattern.
    # BASH_REMATCH[1] is the string matched by the first capture group (the test method name).
    test_name="${BASH_REMATCH[1]}"
    echo "-run '.*/$test_name'"
    return 0 # Success
  fi

  return 1 # No match found
}
# Check if line_content is non-empty.
# - If sed found the line (even an empty line), line_content will contain at least a newline
#   character, so it will not be an empty string.
# - If sed did not find the line (because requested_line_num was too high for the file),
#   line_content will be an empty string.
if [ -n "$line_content" ]; then
    # The line exists, print its content.
    # echo will print the content. If the line was empty, it prints a blank line.
    extract_test_name_from_line "$line_content"
    last_status=$?
    if [ $last_status -ne 0 ]; then
        # Try for suite type
        extract_method_test_name_from_line "$line_content"
        last_status=$?
        if [ $last_status -ne 0 ]; then
            echo "-run '.*'"
        fi
    fi
else 
    echo "-run '.*'"
fi

# Exit with 0 as "notfound" is an expected outcome based on input.
exit 0