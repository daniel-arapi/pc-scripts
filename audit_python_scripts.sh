#!/bin/bash

: '
This script audits Python scripts in a specified directory and generates a CSV report with details such as:

- Script owner and group
- Shebang line
- Git repository status
- Presence of README and requirements files
- Python version

Usage:
    ./audit_python_scripts.sh /path/to/directory

Arguments:
    /path/to/directory: Directory containing Python scripts to be audited. 

The script excludes directories named "venv" and saves the report to a file named "report.csv" in the current directory.
'

# Function to determine if a file is tracked in git
git_check() {
  file_path="$1"
  dir_path=$(get_git_root "$file_path")

  if [[ -n "$dir_path" ]]; then
    check_git_tracking "$file_path" "$dir_path"
    check_readme "$dir_path"
    check_requirements "$dir_path"
  else
    git_repo="Not tracked by git"
    readme_file="None"
    requirements_file="None"
  fi
}

# Function to get the git root directory for a given file
get_git_root() {
  file_path="$1"
  dir_path=$(dirname "$(realpath "$file_path")")

  while [[ "$dir_path" != "/" ]]; do
    if [[ -d "$dir_path/.git" ]]; then
      echo "$dir_path"
      return
    fi
    dir_path=$(dirname "$dir_path")
  done
  echo ""
}

# Function to check if a file is tracked in git
check_git_tracking() {
  file_path="$1"
  dir_path="$2"

  (cd "$dir_path" && git ls-files --error-unmatch "$file_path" > /dev/null 2>&1)
  if [ $? -eq 0 ]; then
    git_repo="$dir_path"
  else
    git_repo="Not tracked by git"
  fi
}

# Function to check if a README file exists in the repository directory
check_readme() {
  dir_path="$1"
  if [[ -f "$dir_path/README.md" ]]; then
    readme_file="$dir_path/README.md"
  elif [[ -f "$dir_path/README.txt" ]]; then
    readme_file="$dir_path/README.txt"
  elif [[ -f "$dir_path/README" ]]; then
    readme_file="$dir_path/README"
  else
    readme_file="None"
  fi
}

# Function to check if a requirements file exists in the repository directory
check_requirements() {
  dir_path="$1"
  if [[ -f "$dir_path/requirements.txt" ]]; then
    requirements_file="$dir_path/requirements.txt"
  else
    requirements_file="None"
  fi
}

# Function to get the owner and group of a file
get_file_owner() {
  file_path="$1"
  owner=$(stat -c "%U" "$file_path")
  group=$(stat -c "%G" "$file_path")
}

# Function to check if a file has a shebang line
check_shebang() {
  file_path="$1"
  first_line=$(head -n 1 "$file_path" | tr -d '\n' | tr -d '\r')
  if [[ $first_line == "#!"* ]]; then
    shebang="$first_line"
  else
    shebang="None"
  fi
}

# Function to determine Python version from shebang line
get_python_version() {
  if [[ $shebang == "#!"*python* ]]; then
    if [[ $shebang == *"python3_"* ]]; then
      python_version=$(echo "$shebang" | grep -oP 'python3_\d+' | sed 's/python3_//' | awk '{print "3."$1}')
    else
      python_version=$(echo "$shebang" | grep -oP 'python[0-9]+(\.[0-9]+)*')
      if [[ -z "$python_version" ]]; then
        python_version="Unknown"
      else
        python_version=${python_version/python/}
      fi
    fi
  else
    python_version="None"
  fi
}

# Function to sanitize data for CSV
sanitize_csv_field() {
  echo "$1" | tr -d '\n' | tr -d '\r'
}

# Main script to search for Python executables, excluding directories containing "venv"
echo "Python script,Owner,Group,Shebang line,Git repository,README file,Requirements file,Python version" > report.csv
find "$1" -type d \( -name "*venv*" -o -name "*venvs*" \) -prune -o -type f -name "*.py" -executable -print | while read -r script; do
  get_file_owner "$script"
  check_shebang "$script"
  get_python_version
  git_check "$script"
  # Sanitize fields to avoid line breaks and ensure all values stay in the same line
  script=$(sanitize_csv_field "$script")
  owner=$(sanitize_csv_field "$owner")
  group=$(sanitize_csv_field "$group")
  shebang=$(sanitize_csv_field "$shebang")
  git_repo=$(sanitize_csv_field "$git_repo")
  readme_file=$(sanitize_csv_field "$readme_file")
  requirements_file=$(sanitize_csv_field "$requirements_file")
  python_version=$(sanitize_csv_field "$python_version")
  # Use printf to handle commas properly
  printf '"%s","%s","%s","%s","%s","%s","%s","%s"\n' "$script" "$owner" "$group" "$shebang" "$git_repo" "$readme_file" "$requirements_file" "$python_version" >> report.csv
  echo "Python script: $script"
  echo "Owner: $owner, Group: $group"
  echo "Shebang line: $shebang"
  echo "Git repository: $git_repo"
  echo "README file: $readme_file"
  echo "Requirements file: $requirements_file"
  echo "Python version: $python_version"
  echo
done

# Convert CSV to Excel using Python
python3 - <<EOF
import pandas as pd

# Read the CSV file
df = pd.read_csv('report.csv')

# Export to Excel
df.to_csv('report.csv', index=False, sep=',')
EOF

