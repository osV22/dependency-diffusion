#!/bin/bash

# OPTIONAL: GitHub API CREDS HERE (public is capped at 60 req/ day)
# Better to spawn a process instead of inserting creds, but that's up to you!
ghUsername=""
ghAPItoken=""
 
logEntry() {
   local id=$(echo $(grep -o ",*{" $outputLoc | wc -l)+1 | bc) 
   local date=$(date --iso-8601=seconds)
   local package=$packageName
   local pip_version=$pipVersion
   local user=$(whoami)
 
   local warning_given="INSTALL WARNING: The '$packageName' package you tried installing does not meet the minimum repository $1 requirement set by your administrator."
   local action_taken="The incident has been recorded in: $outputLoc"
 
   # more checks later
   if [[ $1 == "sudo_install" ]]; then
      local warning_given="INSTALL WARNING: SUDO INSTALL DETECTED. DO NOT USE SUDO WHEN INSTALLING PACKAGES"
      local problem="SUDO INSTALL"
   elif [[ $1 == "broken_link" ]]; then
      local warning_given="WARNING: No GitHub repository URL link detected for the '$packageName' package"
      local problem="Broken Link"
   elif [[ $1 == "stars" ]]; then
      local problem="Repository star count: $repoStars stars... Minimum stars required: $minStars"
   elif [[ $1 == "age" ]]; then
      local problem="Repository age: $repoAge days old... Minimum age required: $minStars"
   else 
      local problem="Two or more dependency-diffusion minimum requirements were not met for the $packageName package."
   fi
 
   echo -e "\n[!] Problem: $problem\n[!] $warning_given\n[+] Note: $action_taken\n"
 
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
 
   if [[ $(grep -o ",*{" $outputLoc | wc -l) == 0 ]]; then
      echo "[" >> $outputLoc # in case user deletes contents, no need to re-run setup
   fi
   if [[ $id > 1 ]]; then
      echo -e ",$report\n]" >> $outputLoc # b/c json_pp does not do tabs/ non-json formats
   else
      echo -e "$report\n]" >> $outputLoc
   fi
 
   # Unformatted, regular JSON 
   #echo "$jsonTemp" | tr -d '\n' | tr -d ' '
}
 
while getopts "c:t:p:a:s:v:o:" arg; do #Later add v: for verbose
   case $arg in
      c) cmd=$OPTARG;;
      t) pipVersion=$OPTARG;;
      p) packageName=$OPTARG;;
      a) minAge=$OPTARG;;
      s) minStars=$OPTARG;;
      v) verbose=$OPTARG;;
      o) outputLoc=$OPTARG;; 
   esac
done
 
# Silent so user does not notice anything
pypiUrl="https://pypi.org/project/$packageName/"
packagePage=$(curl -s $pypiUrl | grep "github.com/repos/")  
 
author=$(echo $packagePage | cut -f5 -d/)
 
# GitHub Repo Page
ghRepoUrl="https://api.github.com/repos/$author/$packageName"
ghRepoInfo=$(exec 
   curl -s \
      -H "Accept: application.vnd.github.v3+json" \
      -u $ghUsername:$ghAPItoken $ghRepoUrl
)
 
if [[ $ghRepoInfo == *"Moved Permanently"* ]]; then
   ghArr=($ghRepoInfo)
   movedUrl=$(echo "${ghArr[5]}" | tr -d '",') 
 
   ghRepoInfo=$(exec 
   curl -s \
      -H "Accept: application.vnd.github.v3+json" \
      -u $ghUsername:$ghAPItoken $movedUrl
   )
fi
 
# Stars Num
declare -i repoStars=$(echo $ghRepoInfo | grep -o "stargazers_count\": .*" | awk '{print $2}' | tr -d '",:' ) 
 
# Get Repo Age
currentDate=$(date '+%y-%m-%d')
createdAt=$(echo $ghRepoInfo | grep -o "created_at\": .*" | awk '{print $2}' | tr -d '",:' | awk -F"T" '{print $1}' ) 
repoAge=$(( ($(date -d "$currentDate" +%s) - $(date -d "$createdAt" +%s)) / (60*60*24) ))
 
if [[ " ${cmd} " == *" sudo "*  ]]; then
   logEntry "sudo_install"
elif [[ $packagePage != *"github.com/repos/"* ]]; then
   logEntry "broken_link"
   exit 1
elif [[ $repoStars -lt $minStars ]] && [[ $repoAge -lt $minAge ]]; then
   logEntry "age and star count"
elif [[ $repoAge -lt $minAge ]]; then
   logEntry "age"
elif [[ $repoStars -lt $minStars ]]; then
   logEntry "stars" 
fi
 
if [[ $verbose == "true" ]]; then
   echo -e "\nDependency-Diffusion: Pip Package Install Detected"
   echo -e "[+] Package Info:"
   echo -e "\tName: $packageName"
   echo -e "\tAuthor: $author"
   echo -e "\tStats: (Age) $repoAge days old, (Stars) $repoStars"
   echo -e "\tDate Created: $createdAt"
   echo -e "\tPyPI URL: $pypiUrl"
   echo -e "\tGitHub Repo URL: $ghRepoUrl"
   echo
   echo -e "[+] Logging Script Info:"
   echo -e "\tVerbose Mode Enabled: $verbose"
   echo -e "\tMinimum Age Required: $minAge"
   echo -e "\tMinimum Stars Required: $minStars"
   echo -e "\tLog file: $outputLoc"
   echo
   echo -e "[+] Commnad Info:"
   echo -e "\tCommnad Entered: $cmd"
   echo -e "\tPip Version Called: $pipVersion"
   echo
fi
