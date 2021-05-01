#!/bin/bash
 
reqsArr=(pip pip3 curl)
reqsMet=()
 
re='^[0-9]+$'
instLocation=~/
logFileDest=~/
verbose="false" #! TODO: implement verbose mode to checkPackage 
 
printHelp() {
   # Display Help
   echo "Dependency-Diffusion - Filter, log, and block suspicious python packages."
   echo
   echo "Usage: ./setup.sh [-h | -a -s -o]"
   echo "options:"
   echo -e "\t-h   Print the help page."
   echo -e "\t-a   Set the minimum age requirement of a package in days."
   echo -e "\t-s   Set the minimum stars requirement for a package's GitHub repo."
   echo -e "\t-o   Creates a log file for all reported packages, JSON format."
   echo -e "\t-v   Verbose mode. Only recommended for debugging. [-v true] to enable. Prints \n\t\tPyPI & GitHub package URL and their stats before every package install."
   echo -e "\n\nExample: bash setup.sh -a 90 -s 29 -o bad_package_log.json"
   echo -e "\nExample: bash setup.sh -a 90 -s 29 -v true -o bad_package_log.json\n"
   echo
}
 
preCheck() {
   local reqCheck=$( which $1 | grep -o ".*$1*." && echo "its Here") 
   if [[ ! -z "$reqCheck" ]]; then
      reqsMet+=("$1")
   fi
}
 
logFile() {
   if [[ ! -d "$logDirectory" ]]; then
      echo -e "\t∟ No directory specified for the log, defaulting to \e[96m$logDirectory\e[0m"
      echo -e "\t\e[92m∟ Log for reported packages can be found at\e[0m \e[96m$instLocation$logFile\e[0m"
      echo -e "[\n" > $instLocation$logFile
   else
   echo -e "\t\e[92m∟ Log for reported packages can be found at\e[0m \e[96m$outputLoc\e[0m"
   echo -e "[\n" > $outputLoc
   fi
}
 
for i in "${reqsArr[@]}"; do 
   preCheck "$i"; 
done
 
while getopts "ha:s:v:o:" arg; do #Later add v: for verbose
   case $arg in
      h) printHelp && exit;;
      a) minAge=$OPTARG;;
      s) minStars=$OPTARG;;
      v) verbose=$OPTARG;;
      o) outputLoc=$OPTARG;;
   esac
done
 
logDirectory="${outputLoc%/*}"
logFile="${outputLoc##*/}"
 
if [[ "$#" -lt 6 ]]; then
   echo -e "\n\e[101m[!] Install FAILED: MISSING ARGUMENT(s)\e[0m\n">&2; 
   printHelp
   exit 1
   if ! [[ $minAge =~ $re ]] && [[ $minStars =~ $re ]]; then
      echo -e "\n\e[101m[!] Install FAILED: wrong data type input\e[0m">&2;
      echo -e "Please enter an integer value (ex: 1,2,3...) for the minimum age and stars\n" 
      printHelp
      exit 1
   fi
fi
 
echo -e "\e[93m[+]\e[0m 1. Checking Requirements"
echo -e "\t\e[92m∟ Reqs Met: ${reqsMet[@]}\e[0m"
 
if [[ ! " ${reqsMet[*]} " == *" curl "* ]]; then
   echo ""
   printf "\nFAILED: cURL NOT FOUND! Failed to find curl. Please install it and try again: apt-get install curl\n\n"
   echo ""
   exit
fi
 
echo ""
 
if [[ ! " ${reqsMet[*]} " == *" pip3 "* ]] && [[ ! " ${reqsMet[*]} " == *" pip "* ]]; then
   echo ""
   printf "\nFAILED: PIP NOT FOUND! Failed to find pip/ pip3. Please install either one and try again\n\n"
   echo ""
else
   if [[ -f "$instLocation.bashrc" ]]; then
      echo -e "\e[93m[+]\e[0m 2. Checking for .bashrc"
      echo -e "\t\e[92m∟ Found .bashrc at $instLocation.bashrc\e[0m"
      cd $installLoc # Just to be safe
 
      echo -e "\n\e[93m[+]\e[0m 3. Installing @rcaloras's bash-preexec from github"
      # @rcaloras's bash-preexec - allows us to run robust custom hook functions
      if [[ ! -f "$instLocation.bash-preexec.sh" ]]; then
      curl -s https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
      fi
 
      echo -e "\e[93m[+]\e[0m 4. Generating a pre-exec function to detect pip installs"
      echo -e "\t\e[92m∟ Saved \e[96mdiffusion-preexec.sh\e[0m in $instLocation\e[0m"
 
 
      echo -e "\n\e[93m[+]\e[0m 5. Adding \e[96mbash-preexec.sh\e[0m and \e[96mdiffusion-preexec.sh\e[0m function to .bashrc"
      # NOTE: MUST BE THE LAST ENTRY IN YOUR BASH CONFIG FILE (~/.bashrc, ~/.profile, ~/.bash_profile, etc).
      #echo "[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh && source ~/diffusion-preexec.sh" >> .bashrc
 
      echo -e "\n\e[93m[+]\e[0m 6. Creating a log file for bad/ reported packages"
 
      if [[ ! -d "$logDirectory" ]] && [[ ! ${logFile: -5} == ".json" ]]; then
         echo -e "\n\e[101m[!] Install FAILED: $logDirectory is not a valid directory to save your logs in!\e[0m\n">&2;
 
      elif [[ -z "$logFile" ]]; then
         echo "ERROR: NO FILE SPECIFIED TO SAVE LOGS"
         #exit 1  
      else
         logFile
      fi
 
      echo -e "\n\e[93m[+]\e[0m 7. Updating/ refreshing your bash configuration file"
      #source ~/.bashrc
   else 
      echo "DID NOT FIND .bashrc in $instLocation, bye"
   fi
fi
 
 
echo '
preexec() { 
   local minAge='$minAge'
   local minStars='$minStars'
   local outputLoc='$outputLoc'
 
   local cmd=${1,,}
   echo "Command Entered: $cmd"
 
   local cmdArr=($cmd)
 
   if [[ " ${cmd} " == *" sudo "*  ]]; then
      local packageName="${cmdArr[@]:3}"
   else
      local packageName="${cmdArr[@]:2}"
   fi
 
   case "$cmd" in 
      "pip install "[0-9a-z]* | "sudo pip install "[0-9a-z]*)
         # Pip Procedure
         echo "x-x-x-x- pip install"
         requestCheck "pip"
      ;;
      "pip3 install "[0-9a-z]* | "sudo pip3 install "[0-9a-z]*)
         # Pip3 Procedure
         echo "x-x-x-x- PIP 3 CALLED" 
         requestCheck "pip3"
      ;;
   esac
 
   function requestCheck() {
      echo "Pip Version: pip $1"
      echo "Package Name: $packageName"
      bash reportPackage.sh -c "$cmd" -t "$1" -p "$packageName" -a $minAge -s $minStars -o "$outputLoc"
   }  
}
' > diffusion-preexec.sh 

