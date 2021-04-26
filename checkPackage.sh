#!/bin/bash
 
# GitHub API CREDS HERE (OPTIONAL, public is capped at 60 req/ day)
# Better to spawn a process instead of inserting creds, but that's up to you!
ghUsername=""
ghAPItoken=""
 
reason=""
warning_given=""
action_taken=""
 
 
while getopts "p:a:s:o:" arg; do #Later add v: for verbose
   case $arg in
      p) packageName=$OPTARG;;
      a) minAge=$OPTARG;;
      s) minStars=$OPTARG;;
      o) outputLoc=$OPTARG;; 
   esac
done
 
 
echo "---- reportPackage REACHED-------"
echo "Package Name: $packageName"
echo "Output Loc: $outputLoc"
echo "Age Min: $minAge"
echo "Stars Min: $minStars"
 
# Get Page from PyPI | silent so user does not notice anything
pypiUrl="https://pypi.org/project/$packageName/"
packagePage=$(curl -s $pypiUrl | grep "github.com/repos/") 
 
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
declare -i repoStars=$(echo $ghRepoInfo | grep -o "stargazers_count\": .*" | awk '{print $2}' | tr -d '",:' ) # I guess I'm into self-harm at this point
echo "Total Stars: $repoStars"
 
 
# Get Repo Age
currentDate=$(date '+%y-%m-%d')
 
createdAt=$(echo $ghRepoInfo | grep -o "created_at\": .*" | awk '{print $2}' | tr -d '",:' | awk -F"T" '{print $1}' ) # I guess I'm into self-harm at this point
echo "Created on: $createdAt"
 
repoAge=$(( ($(date -d "$currentDate" +%s) - $(date -d "$createdAt" +%s)) / (60*60*24) ))
echo "Repo age: $repoAge days old"
 
 
logEntry() {
 
   local warningNote="[!] INSTALL WARNING: The \"$packageName\" package you tried installing does not meet the minimum repository $1 requirement set by your administrator."
   local actionNote="[+] To protect you from a possibly malicious/ misspelled packages, the incident will be logged and package uninstalled"
 
   local id=$(echo $(grep -o "}," log.json | wc -l)+1 | bc) # CHANGE TO CORRECT FILE LATER
   local date=$(date --iso-8601=seconds)
   local package=$packageName
   local pip_version=3
   local user=$(whoami)
   local warning_given=$warningNote
   local action_taken=$actionNote
   local reason_given=$reason
 
 
   if [[ $1 == "stars" ]]; then
      reason="[+] Repository star count: $repoStars stars... Minimum stars required: $minStars"
   elif [[ $1 == "age" ]]; then
      reason="[+] Repository age: $repoAge days old... Minimum age required: $minStars"
   else
      #! TODO: Finish this part and move on to uninstall process
      echo wow both not met!!
   fi
 
   echo -e "\n$warningNote\n$actionNote\n$reason\n"
 
 
   jsonTemp='
      {
         "id":"%s",
         "date":"%s",
         "package":"%s", 
         "pypi_url":"%s", 
         "github_url":"%s", 
         "pip_version":"%s",
         "user":"%s",
         "reason":"%s",
         "warning_given":"%s",
         "action_taken":"%s"
      }'
   report=$(printf "$jsonTemp" "$id" "$date" "$package" "$pypiUrl" "$ghRepoUrl" "$pip_version" "$user" "$reason" "$warning_given" "$action_taken")
   sed -i '$ d' log.json
   echo -e "$report,\n]" >> log.json # b/c json_pp does not do tabs/ non-json formats
 
   # For regular json. 
   #echo "$jsonTemp" | tr -d '\n' | tr -d ' '
}
 
 
if [[ $repoStars -lt $minStars ]] && [[ $repoAge -lt $minAge ]]; then
   logEntry "age and star count"
elif [[ $repoAge -lt $minAge ]]; then
   logEntry "age"
elif [[ $repoStars -lt $minStars ]]; then
   logEntry "stars" 
else
   echo "STARRED! PASSED"
   printf "\nstar count: $repoStars\nmin stars req: $minStars\n\n"
fi