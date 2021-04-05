#!/bin/bash
 
reqsArr=(pip pip3 curl)
reqsMet=()
instLocation=~/
 
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
		curl -s https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
 
		echo -e "\e[93m[+] 4. Adding \e[96mbash-preexec.sh\e[0m \e[93mand \e[96mdependency-diffusion.sh\e[0m \e[93mfunction to .bashrc\e[0m"
		# NOTE: MUST BE THE LAST ENTRY IN YOUR BASH CONFIG FILE (~/.bashrc, ~/.profile, ~/.bash_profile, etc).
		#echo "[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh && source ~/pureFunc.sh" >> .bashrc
 
		echo -e "\e[93m[+] 5. Updating/ refreshing your bash configuration file\e[0m"
		#source ~/.bashrc
	fi
fi
 
 
 
 
#getReq() {
#	echo "It seems that you do not have the following:"
#	echo "$1 and $2"
#}
 
 
#echo $bashFile >> "source ~/.bash-preexec.sh" 