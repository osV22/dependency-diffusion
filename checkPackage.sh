#!/bin/bash
 
# GitHub API CREDS HERE (OPTIONAL, public is capped at 60 req/ day)
# Better to spawn a process instead of inserting creds, but that's up to you!
ghUsername=""
ghAPItoken=""
 
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
packagePage=$(curl -s https://pypi.org/project/$packageName/ | grep "github.com/repos/") 
 
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
declare -i starCount=$(echo $ghRepoInfo | grep -o "stargazers_count\": .*" | awk '{print $2}' | tr -d '",:' ) # I guess I'm into self-harm at this point
echo "Total Stars: $starCount"
 
if [[ $starCount -lt $minStars ]]; 
then
   echo "Not STARRED ENOUGH! FAILED"
   printf "\nstar count: $starCount\nmin stars req: $minStars\n\n"
 
else
   echo "STARRED! PASSED"
   printf "\nstar count: $starCount\nmin stars req: $minStars\n\n"
fi
 
 
# Get Repo Age
currentDate=$(date '+%y-%m-%d')
 
createdAt=$(echo $ghRepoInfo | grep -o "created_at\": .*" | awk '{print $2}' | tr -d '",:' | awk -F"T" '{print $1}' ) # I guess I'm into self-harm at this point
echo "Created on: $createdAt"
 
repoAge=$(( ($(date -d "$currentDate" +%s) - $(date -d "$createdAt" +%s)) / (60*60*24) ))
echo "Repo age: $repoAge days old"
 
if [[ $repoAge -lt $minAge ]]; 
then
   echo "Repo is very NEW! FAILED"
 
 
else
   echo "Package is OLD enough! PASSED"
   # TRIGGER a log entry
   id=1
   date="12/12/12"
   package="matplotlib"
   pip_version=3
   user="x"
   reason="Package only has x stars, which is y less than the minimum set in the diffusion-preexec function."
   warning_given="Package is too new and has been uninstalled."
   action_taken="Uninstalled"
 
 
   jsonTemp='
      {
         "id":"%s",
         "date":"%s",
         "package":"%s", # change to array later on 
         "pip_version":"%s",
         "user":"%s",
         "reason":"%s",
         "warning_given":"%s",
         "action_taken":"%s"
      }'

   #! TODO: Wrap in an if-else and insert arr start if empty, add actual vars, 
   report=$(printf "$jsonTemp" "$id" "$date" "$package" "$pip_version" "$user" "$reason" "$warning_given" "$action_taken")
   sed -i '$ d' log.json
   echo -e "$report,\n]" >> log.json # b/c json_pp does not do tabs/ non-json formats
 
   # For regular json. 
   #echo "$jsonTemp" | tr -d '\n' | tr -d ' '
 
fi