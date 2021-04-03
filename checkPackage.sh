#!/bin/bash
 
# API CREDS HERE
 
 
while getopts "p:a:s:" arg; do #Later add v: for verbose
	case $arg in
		p) packageName=$OPTARG;;
		a) age=$OPTARG;;
		s) stars=$OPTARG;;
	esac
done
 
 
echo "---- reportPackage REACHED-------"
echo "Package Name: $packageName"
echo "Age Min: $age"
echo "Stars Min: $stars"
 
 
# Get Page from PyPI
packagePage=$(curl -s https://pypi.org/project/$packageName/ | grep "github.com/repos/") # silent so user does not notice anything
 
#echo $packagePage
 
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
 
echo $ghRepoInfo
 
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
 
 
# Get Repo Age
currentDate=$(date '+%y-%m-%d')
 
createdAt=$(echo $ghRepoInfo | grep -o "created_at\": .*" | awk '{print $2}' | tr -d '",:' | awk -F"T" '{print $1}' ) # I guess I'm into self-harm at this point
echo "Created on: $createdAt"
 
repoAge=$(( ($(date -d "$currentDate" +%s) - $(date -d "$createdAt" +%s)) / (60*60*24) ))
echo $repoAge
 
if [[ $repoAge -lt 4000 ]]; 
then
   echo "Repo is very NEW! FAILED"
else
   echo "Package is OLD enough! PASSED"
fi