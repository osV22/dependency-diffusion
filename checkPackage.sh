#!/bin/bash
 
# OPTIONAL: GitHub API CREDS HERE (public is capped at 60 req/ day)
# Better to spawn a process instead of inserting creds, but that's up to you!
ghUsername=""
ghAPItoken=""
 
reason=""
warning_given=""
action_taken=""
 
 
while getopts "c:t:p:a:s:o:" arg; do #Later add v: for verbose
   case $arg in
      c) cmd=$OPTARG;;
      t) pipVersion=$OPTARG;;
      p) packageName=$OPTARG;;
      a) minAge=$OPTARG;;
      s) minStars=$OPTARG;;
      o) outputLoc=$OPTARG;; 
   esac
done
 
# if [[]]; then
# fi
echo "---- reportPackage REACHED-------"
echo "Commnad Entered: $cmd"
echo "Pip Version Called: $pipVersion"
echo "Package Name: $packageName"
echo "Output Loc: $outputLoc"
echo "Age Min: $minAge"
echo "Stars Min: $minStars"
 
# Get Page from PyPI | silent so user does not notice anything
pypiUrl="https://pypi.org/project/$packageName/"
packagePage=$(curl -s $pypiUrl | grep "github.com/repos/")  
 
# Get Author
echo "--------"
author=$(echo $packagePage | cut -f5 -d/)
echo "Author is: $author"
 
# GitHub Repo Page
ghRepoUrl="https://api.github.com/repos/$author/$packageName"
ghRepoInfo=$(exec 
   curl -s \
      -H "Accept: application.vnd.github.v3+json" \
      -u $ghUsername:$ghAPItoken $ghRepoUrl
)
 
#moved=$(echo $ghRepoInfo | grep "Moved Permanently")
 
if [[ $ghRepoInfo == *"Moved Permanently"* ]]; then
   echo "---------- MOVED ----------"
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
declare -i repoStars=$(echo $ghRepoInfo | grep -o "stargazers_count\": .*" | awk '{print $2}' | tr -d '",:' ) 
echo "Total Stars: $repoStars"
 
 
# Get Repo Age
currentDate=$(date '+%y-%m-%d')
createdAt=$(echo $ghRepoInfo | grep -o "created_at\": .*" | awk '{print $2}' | tr -d '",:' | awk -F"T" '{print $1}' ) 
echo "Created on: $createdAt"
repoAge=$(( ($(date -d "$currentDate" +%s) - $(date -d "$createdAt" +%s)) / (60*60*24) ))
echo "Repo age: $repoAge days old"
 
logEntry() {
   local warningNote="INSTALL WARNING: The '$packageName' package you tried installing does not meet the minimum repository $1 requirement set by your administrator."
   local actionNote="The incident has been recorded in the log in: $outputLoc"
 
   # more checks later
   if [[ $1 == "sudo install" ]]; then
      local warningNote="INSTALL WARNING: SUDO INSTALL DETECTED. DO NOT USE SUDO WHEN INSTALLING PACKAGES"
      local problem="SUDO INSTALL"
   elif [[ $1 == "broken link" ]]; then
      local warningNote="WARNING: No GitHub repository URL link detected"
      local problem="Broken Link"
   elif [[ $1 == "stars" ]]; then
      local problem="Repository star count: $repoStars stars... Minimum stars required: $minStars"
   elif [[ $1 == "age" ]]; then
      local problem="Repository age: $repoAge days old... Minimum age required: $minStars"
   else 
      local problem="Two or more dependency-diffusion minimum requirements were not met for the package to be installed."
   fi
 
   local id=$(echo $(grep -o "}," $outputLoc | wc -l)+1 | bc) 
   local date=$(date --iso-8601=seconds)
   local package=$packageName
   local pip_version=$pipVersion
   local user=$(whoami)
   local warning_given=$warningNote
   local action_taken=$actionNote
   local problem_given=$problem
 
   echo -e "\n[!] Problem: $problem\n[!] $warningNote\n[+] Note: $actionNote\n"
 
   jsonTemp='
      {
         "id":"%s",
         "date":"%s",
         "command":"%s",
         "package":"%s", 
         "pypi_url":"%s", 
         "github_url":"%s", 
         "pip_version":"%s",
         "user":"%s",
         "problem":"%s",
         "warning_given":"%s",
         "action_taken":"%s"
      }'
   report=$(printf "$jsonTemp" "$id" "$date" "$cmd" "$package" "$pypiUrl" "$ghRepoUrl" "$pip_version" "$user" "$problem" "$warning_given" "$action_taken")
   sed -i '$ d' $outputLoc
   echo -e "$report,\n]" >> $outputLoc # b/c json_pp does not do tabs/ non-json formats
 
   # Unformatted, regular JSON 
   #echo "$jsonTemp" | tr -d '\n' | tr -d ' '
}
 
 
if [[ " ${cmd} " == *" sudo "*  ]]; then
   logEntry "sudo install"
elif [[ $packagePage != *"github.com/repos/"* ]]; then
   logEntry "broken link"    
elif [[ $repoStars -lt $minStars ]] && [[ $repoAge -lt $minAge ]]; then
   logEntry "age and star count"
elif [[ $repoAge -lt $minAge ]]; then
   logEntry "age"
elif [[ $repoStars -lt $minStars ]]; then
   logEntry "stars" 
fi

