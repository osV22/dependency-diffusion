#!/bin/bash
# An example of the .diffusion-preexec.sh that is generated during setup
preexec_diffusion() { 
   local minAge=99
   local minStars=9
   local outputLoc="~/"
   local verbose="true"
   local cmd=${1,,}
   local cmdArr=($cmd)
 
   if [[ " ${cmd} " == *" sudo "*  ]]; then
      local packageName="${cmdArr[@]:3}"
   else
      local packageName="${cmdArr[@]:2}"
   fi
    case "$cmd" in 
      "pip install "[0-9a-z]* | "sudo pip install "[0-9a-z]*)
         requestCheck "pip"
      ;;
      "pip3 install "[0-9a-z]* | "sudo pip3 install "[0-9a-z]*)
         requestCheck "pip3"
      ;;
   esac
   function requestCheck() {
      bash reportPackage.sh -c "$cmd" -t "$1" -p "$packageName" -a $minAge -s $minStars -v "$verbose" -o "$outputLoc"
   }  
}
