#!/bin/bash
 
preexec() { 
	local minAge=1337
	local minStars=1337
 
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
     "pip5 install "[0-9a-z]*) # Will change to pip3 later
       # Pip3 Procedure
       echo "x-x-x-x- PIP 5 CALLED" # Testing, don't want to trigger an actual request
       requestCheck "3"
      ;;
   esac
 
   function requestCheck() {
      echo "Pip Version: pip $1"
      echo "Package Name: $packageName"
      bash reportPackage.sh -p "$packageName" -a $minAge -s $minStars
   }  
}