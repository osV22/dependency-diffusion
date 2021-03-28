#!/bin/bash

# PRE-CHECKS:
    # which python
    # which pip
    # which curl

# Get Page from PyPI
packagePage=$(curl -s https://pypi.org/project/opencv-python/ | grep "github.com/repos/") # silent so user does not notice anything

# Clean if-else statement
# [[ ${packagePage} != *"github.com"* ]] && echo "FAIL"
# exit


# Check if there is a valid repo:
if [[ $packagePage != *"github.com/repos/"* ]]; then
  echo "FAIL, Link Broken"
  exit
fi


echo "--------"
# Get Author and Repo Name
echo $packagePage | cut -f5 -d/

echo "--------"
echo $packagePage | grep -o -P '(?<=repos/).*(?=opencv-python)'


# Repo Name Parsed, use function input instead
y=$(echo $packagePage | cut -f6 -d/)
echo $y | awk -F '"' '{print $1""}'

