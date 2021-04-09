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
   echo "-h     Print the help page."
   echo "-a     Set the minimum age requirement of a package in days. Ex. (365 = 1 year old package)"
   echo "-s     Set the minimum stars requirement for a package's GitHub repo."
   echo "Example: ./setup.sh -a 365 -s 1337"
   echo
}
 
while getopts "ha:s:" arg; do #Later add v: for verbose
	case $arg in
    	h) Help && exit;;
		a) minAge=$OPTARG;;
		s) minStars=$OPTARG;;
	esac
done
 
 
if [ "$#" -lt 3 ]; then
   echo -e "\n\e[101m[!] Install FAILED: MISSING AN ARGUMENT\e[0m\n">&2; 
   Help
   exit 1
 
   if ! [[ $minAge =~ $re ]] && [[ $minStars =~ $re ]] ; then
      echo -e "\n\e[101m[!] Install FAILED: wrong data type input\e[0m">&2;
      echo -e "Please enter an integer value (ex: 1,2,3...) for the minimum age and stars\n" 
      Help
      exit 1
   fi
 
   #! TODO: Add file output directory requirements for reported package log
   if [[ -z "$@" ]]; then
      echo >&2 "You must supply an argument!"
      exit 1
   elif [[ ! -d "$@" ]]; then
      echo >&2 "$@ is not a valid directory!"
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
 
echo -e "\e[93m[+] 1. Checking Requirements\e[0m"
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
		echo -e "\e[93m[+] 2. Checking for .bashrc\e[0m"
		echo -e "\t\e[92m∟ Found .bashrc at $instLocation.bashrc\e[0m"
		cd $installLoc 
 
		echo -e "\n\e[93m[+] 3. Installing @rcaloras's bash-preexec from github\e[0m"
		# @rcaloras's bash-preexec - allows us to run robust custom hook functions
		if [[ ! -f "$instLocation.bash-preexec.sh" ]]; then
			curl -s https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
		fi
 
		echo -e "\e[93m[+] 4. Generating a pre-exec function to detect pip installs\e[0m"
		echo -e "\t\e[92m∟ Saved \e[96mpreexec-diffusion.sh\e[0m in $instLocation\e[0m"
		# NOTE: MUST BE THE LAST ENTRY IN YOUR BASH CONFIG FILE (~/.bashrc, ~/.profile, ~/.bash_profile, etc).
 
 
		echo -e "\e[93m[+] 5. Adding \e[96mbash-preexec.sh\e[0m \e[93mand \e[96mdependency-diffusion.sh\e[0m \e[93mfunction to .bashrc\e[0m"
		# NOTE: MUST BE THE LAST ENTRY IN YOUR BASH CONFIG FILE (~/.bashrc, ~/.profile, ~/.bash_profile, etc).
		#echo "[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh && source ~/pureFunc.sh" >> .bashrc
 
		echo -e "\e[93m[+] 6. Updating/ refreshing your bash configuration file\e[0m"
		#source ~/.bashrc
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
      ;;
   esac
 
   function requestCheck() {
      echo "Pip Version: pip $1"
      echo "woot"
      echo "Package Name: $packageName"
      bash reportPackage.sh -p "$packageName" -a $minAge -s $minStars
   }  
}
' > preexec-diffusion.sh 