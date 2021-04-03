#!/bin/bash
 
reqsArr=(pip pip3 curl)
reqsMet=()
reqTest=(piwwp piwwp3)
 
preCheck() {
   local reqCheck=$( which $1 | grep -o ".*$1*." && echo "its Here") 
	if [[ ! -z "$reqCheck" ]]; then
      reqsMet+=("$1")
	fi
}
 
for i in "${reqsArr[@]}"; do 
	preCheck "$i"; 
done
 
 
echo "Reqs Met: ${reqsMet[@]}"
echo "Total Reqs Met: ${#reqsMet[@]}"
 
 
if [[ ! " ${reqsMet[*]} " == *" curl "* ]] ; then
	echo ""
	printf "\nFAILED: cURL NOT FOUND! Failed to find curl. Please install it and try again: apt-get install curl\n\n"
	echo ""
fi
 
echo ""
 
if [[ ! " ${reqsMet[*]} " == *" pip3 "* ]] && [[ ! " ${reqsMet[*]} " == *" pip "* ]] ; then
	echo ""
	printf "\nFAILED: PIP NOT FOUND! Failed to find pip/ pip3. Please install either one and try again\n\n"
	echo ""
else
	echo "BEGIN INSTALL PROCESS"
fi
 
 
rcFile=~/.bashrc
 
if [[ -f "$rcFile" ]]; then
   echo "Found bashrc"
fi
 
 
#getReq() {
#	echo "It seems that you do not have the following:"
#	echo "$1 and $2"
#}
 
#echo $bashFile >> "source ~/.bash-preexec.sh" 