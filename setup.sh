#!/bin/bash
 
reqsArr=(pip pip3 curl)
reqsMet=()
 
re='^[0-9]+$'
instLocation=~/
 
Help()
{
   # Display Help
   echo "Dependency-Diffusion - Filter, log, and block suspicious python packages."
   echo
   echo "Syntax: bash setup.sh [-h | -a -s]"
   echo "options:"
   echo -e "\t-h     Print the help page."
   echo -e "\t-a     Set the minimum age requirement of a package in days."
   echo -e "\t-s     Set the minimum stars requirement for a package's GitHub repo."
   echo -e "\nExample: ./setup.sh -a 365 -s 1337"
   echo
}
 
while getopts "ha:s:o:" arg; do 
	case $arg in
      h) Help && exit;;
		a) minAge=$OPTARG;;
		s) minStars=$OPTARG;;
      o) outputLoc=$OPTARG;;
	esac
done
 
 
if [ "$#" -lt 6 ]; then
   echo -e "\n\e[101m[!] Install FAILED: MISSING AN ARGUMENT\e[0m\n">&2; 
   Help
   exit 1
 
   if ! [[ $minAge =~ $re ]] && [[ $minStars =~ $re ]] ; then
      echo -e "\n\e[101m[!] Install FAILED: wrong data type input\e[0m">&2;
      echo -e "Please enter an integer value (ex: 1,2,3...) for the minimum age and stars\n" 
      Help
      exit 1
   fi
 
fi
 
preCheck() {
   local reqCheck=$( which $1 | grep -o ".*$1*." && echo "its Here") 
	if [[ ! -z "$reqCheck" ]]; then
      reqsMet+=("$1")
	fi
}
 
for i in "${reqsArr[@]}"; do 
	preCheck "$i"; 
done
 
echo -e "\e[93m[+]\e[0m 1. Checking Requirements"
echo -e "\t\e[92m∟ Reqs Met: ${reqsMet[@]}\e[0m"
 
if [[ ! " ${reqsMet[*]} " == *" curl "* ]] ; then
	echo ""
	printf "\nFAILED: cURL NOT FOUND! Failed to find curl. Please install it and try again: apt-get install curl\n\n"
	echo ""
	exit
fi
 
echo ""
 
if [[ ! " ${reqsMet[*]} " == *" pip3 "* ]] && [[ ! " ${reqsMet[*]} " == *" pip "* ]] ; then
	echo ""
	printf "\nFAILED: PIP NOT FOUND! Failed to find pip/ pip3. Please install either one and try again\n\n"
	echo ""
else
	if [[ -f "$instLocation.bashrc" ]]; then
		echo -e "\e[93m[+]\e[0m 2. Checking for .bashrc"
		echo -e "\t\e[92m∟ Found .bashrc at $instLocation.bashrc\e[0m"
		cd $installLoc
 
		echo -e "\n\e[93m[+]\e[0m 3. Installing @rcaloras's bash-preexec from github"
		# @rcaloras's bash-preexec - allows us to run robust custom hook functions
      if [[ ! -f "$instLocation.bash-preexec.sh" ]]; then
		curl -s https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
      fi
 
		echo -e "\e[93m[+]\e[0m 4. Generating a pre-exec function to detect pip installs"
		echo -e "\t\e[92m∟ Saved \e[96mpreexec-diffusion.sh\e[0m in $instLocation\e[0m"
		# NOTE: MUST BE THE LAST ENTRY IN YOUR BASH CONFIG FILE (~/.bashrc, ~/.profile, ~/.bash_profile, etc).
 
 
		echo -e "\n\e[93m[+]\e[0m 5. Adding \e[96mbash-preexec.sh\e[0m and \e[96mdependency-diffusion.sh\e[0m function to .bashrc"
		# NOTE: MUST BE THE LAST ENTRY IN YOUR BASH CONFIG FILE (~/.bashrc, ~/.profile, ~/.bash_profile, etc).
		#echo "[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh && source ~/pureFunc.sh" >> .bashrc
 
 
 
      echo "OUT PUT FILE: $outputLoc"
      logDirectory="${outputLoc%/*}"
 
      echo "DIRECTORY: $direct" 
 
      logFile="${outputLoc##*/}"
      echo "LOG FILE: $logFile"
 
      if [[ ! -d "$logDirectory" ]]; then
         echo -e "\n\e[101m[!] Install FAILED: $logDirectory is not a valid directory to save your logs in!\e[0m\n">&2;
         #exit 1
      elif [[ -z "$logFile" ]]; then
         echo "ERROR: NO FILE SPECIFIED TO SAVE LOGS"
         #exit 1
      else
      #! TODO: Lowercase check then begin json reporting on reportPackage
         if [[ ${logFile: -5} == ".json" ]]; then
            echo "JSON IT IS!"
         else
            echo "NOT JSON"
         fi
 
         echo "ALL GOOD"
         echo -e "\n\e[93m[+]\e[0m 6. Creating a logging file"
         echo -e "\t\e[92m∟ Log for reported packages can be found at\e[0m \e[96m$outputLoc\e[0m"
         #touch    
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
 
   local cmd=${1,,}
   echo "Command Entered: $cmd"
 
   local cmdArr=($cmd)
   local packageName="${cmdArr[@]:2}"
 
   case "$cmd" in 
     "pip install "[0-9a-z]*)
       # Pip Procedure
       echo "x-x-x-x- pip install"
       requestCheck
      ;;
     "pip5 install "[0-9a-z]*) #will change to pip3 later
       # Pip3 Procedure
       echo "x-x-x-x- PIP 5 CALLED" #will change to pip3 later
       requestCheck "3"
       echo "STOPPING PROCESS"
      ;;
   esac
 
   function requestCheck() {
      echo "Pip Version: pip $1"
      echo "Package Name: $packageName"
      bash reportPackage.sh -p "$packageName" -a $minAge -s $minStars -o $outputLoc
   }  
}
' > preexec-diffusion.sh 