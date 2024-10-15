#!/bin/bash

# Function to check if a directory is tracked in git
is_tracked_in_git() {
    if git -C "$1" rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Yes"
    else
        echo "No"
    fi
}

# Function to get the author of a script using git
get_file_author() {
    if git -C "$1" log --format='%an' -- "$2" &>/dev/null; then
        git -C "$1" log --format='%an' -- "$2" | tail -n 1
    else
        echo "Unknown (Not tracked in Git)"
    fi
}

# Function to check if there is a README file in the directory
check_for_readme() {
    if [[ -f "$1/README.md" || -f "$1/README" ]]; then
        echo "Yes"
    else
        echo "No"
    fi
}

# Function to check if there is a requirements.txt file in the directory
check_for_requirements() {
    if [[ -f "$1/requirements.txt" ]]; then
        echo "Yes"
    else
        echo "No"
    fi
}

# Function to check if the Python script has a shebang on the first line
has_shebang() {
    if [[ $(head -n 1 "$1") =~ ^#!/.*python ]]; then
        echo "Yes"
    else
        echo "No"
    fi
}

# Function to process Python scripts
process_python_scripts() {
    for pyfile in $(find "$1" -type f -name "*.py"); do
        script_dir=$(dirname "$pyfile")
        echo "Checking file: $pyfile"

        # Check if the directory is tracked in git
        tracked_in_git=$(is_tracked_in_git "$script_dir")

        # Get the author of the file (Git)
        author=$(get_file_author "$script_dir" "$pyfile")

        # Check for README file in the directory
        has_readme=$(check_for_readme "$script_dir")

        # Check for requirements.txt in the directory
        has_requirements=$(check_for_requirements "$script_dir")

        # Check if the Python script has a shebang
        shebang_present=$(has_shebang "$pyfile")

        # Output the information
        echo "File: $pyfile"
        echo "Tracked in Git: $tracked_in_git"
        echo "Author: $author"
        echo "README exists: $has_readme"
        echo "Requirements file exists: $has_requirements"
        echo "Shebang present: $shebang_present"
        echo "==============================================="
    done
}

# Main function to start the search
main() {
    root_directory="$1"
    if [[ -z "$root_directory" ]]; then
        echo "Please provide a root directory to search."
        exit 1
    fi
    process_python_scripts "$root_directory"
}

# Call the main function with the first argument as the root directory
main "$1"
