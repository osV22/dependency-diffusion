#!/bin/bash
 
# Pre-checks
 
reqsArr=(python python3 pip pip3)
reqsMet=()
 
 
preCheck() {
   local pythonCheck=$( which $1 | grep -o ".*$1*." && echo "its Here") 
	if [[ ! -z "$pythonCheck" ]]; then
      reqsMet+=("$1")
 
	fi
}
 
getReq() {
	echo "It seems that you do not have the following:"
	echo "$1 and $2"
}
 
 
for i in "${reqsArr[@]}"; do 
	preCheck "$i"; 
done
 
echo "Reqs Met: ${reqsMet[@]}"
echo "Total Reqs Met: ${#reqsMet[@]}"
 
 
rcFile=~/.bashrc
 
if [[ -f "$rcFile" ]]; then
   echo "Found bashrc"
fi
 
#echo $bashFile >> "source ~/.bash-preexec.sh"