#!/bin/bash
 
# API CREDS HERE
 
while getopts "n:" arg; do
  case $arg in
    n) packageName=$OPTARG;;
  esac
done
 
echo "REACHED and Package Name: $packageName"
 
 
# PRE-CHECKS:
    # which python
    # which pip
    # which curl
 
# Get Page from PyPI
packagePage=$(curl -s https://pypi.org/project/$packageName/ | grep "github.com/repos/") # silent so user does not notice anything
 
# Check if there is a valid repo:
if [[ $packagePage != *"github.com/repos/"* ]]; then
  echo "FAIL, Link Broken"
  exit
fi
 
 
# Get Author
echo "--------"
author=$(echo $packagePage | cut -f5 -d/)
echo "Author is: $author"
 
# GitHub Repo Page
ghRepoInfo=$(exec 
   curl -s \
      -H "Accept: application.vnd.github.v3+json" \
      -u $ghUsername:$ghAPItoken https://api.github.com/repos/$author/$packageName
)
 
echo $ghRepoInfo | grep "Moved Permanently" && echo "MOVED"
 
#moved=$(echo $ghRepoInfo | grep "Moved Permanently")
 
 
if [[ $ghRepoInfo == *"Moved Permanently"* ]]; then
  echo "-------------- MOVED ----------"
  ghArr=($ghRepoInfo)
  #newLocation=$(echo $ghRepoInfo | grep )
  echo ""
  movedUrl=$(echo "${ghArr[5]}" | tr -d '",') 
  echo $movedUrl
 
  ghRepoInfo=$(exec 
   curl -s \
      -H "Accept: application.vnd.github.v3+json" \
      -u $ghUsername:$ghAPItoken $movedUrl
  )
fi
 
#echo $ghRepoInfo
 
# Stars Num
declare -i starCount=$(echo $ghRepoInfo | grep -o "stargazers_count\": .*" | awk '{print $2}' | tr -d '",:' ) # I guess I'm into self-harm at this point
echo "Total Stars: $starCount"
 
if [[ $starCount -gt 10 ]]; then
   echo "Min Star Req Met!"
fi
 
# TODO: Get repo history and find other metrics that are security-worthy
