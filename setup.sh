#!/bin/bash

instLocation=~/
logFileDest=~/
diffusionPrexSh=".diffusion-preexec.sh"
acceptRe="^[0-9]+$"
verbose="false" 
bashConfSource="[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh && source ~/$diffusionPrexSh"
 
reqsArr=(pip pip3 curl)
reqsMet=()
 
printHelp() {
   # Display Help
   echo "Dependency-Diffusion - Log suspicious python package installs."
   echo
   echo "Usage: setup.sh [-h | -a -s -o]"
   echo "options:"
   echo -e "\t-h   Print the help page."
   echo -e "\t-a   Set the minimum age requirement of a package in days."
   echo -e "\t-s   Set the minimum stars requirement for a package's GitHub repo."
   echo -e "\t-o   Creates a log file for all reported packages, JSON format."
   echo -e "\t-v   Verbose mode. Only recommended for debugging. [-v true] to enable. Prints \n\t\tPyPI & GitHub package URL and their stats before every package install."
   echo -e "\n\nExample: bash setup.sh -a 90 -s 29 -o bad_package_log.json"
   echo -e "Example: ./setup.sh -a 90 -s 29 -v true -o bad_package_log.json\n"
   echo -e "GitHub Repo: https://github.com/osV22/dependency-diffusion"
   echo
}
 
reqCheck() {
   local reqCheck=$( which $1 | grep -o ".*$1*.") 
   if [[ ! -z "$reqCheck" ]]; then
      reqsMet+=("$1")
   fi
}
 
logFile() {
   if [[ ! -d "$logDirectory" ]]; then
      echo -e "\t∟ No directory specified for the log, defaulting to \e[96m$(pwd)\e[0m"
      echo -e "\t\e[92m∟ Log for reported packages can be found at\e[0m \e[96m$instLocation$logFile\e[0m"
      echo -e "[\n" > $instLocation$logFile
   else
      echo -e "\t\e[92m∟ Log for reported packages can be found at\e[0m \e[96m$outputLoc\e[0m"
      echo -e "[\n" > $logFile
   fi
}
 
printASCII() {
   echo -e "
                           ,   .                      
     .                    .*   .,                    ,
       .*                 **   .,                .*,  
         ..****,         .**   .,,         ,****..    
             ......****.  .*...*   ,****,.....        
          .,           .. .****** ,.          .,.     
              ....,****(/,,,. ,,,,//****,....         
                      ,*&&,.   ,,%%*,                 
                      .&&,      ,,%%                    
                    ,&&,,         ,,%%                
                    &&,,           ,,%%               
                   (&&,,           ,,%%               
                   (&&, Olofm 2014 ,,%%               
                    &&,,           ,,%%              
  _                                  _             
 / | _   _  _  _   _/ _  _  _    __ / | ._/|_/|     _ . _  _ 
/_.'/_' /_//_'/ //_/ /_'/ //_ /_/  /_.'/ /  /  /_/_\ / /_// /
       /                      _/                              
   "
}
 
makeDiffusionPrex() {
   genNewPrex() {
      echo '
      preexec_diffusion() { 
         local minAge='$minAge'
         local minStars='$minStars'
         local outputLoc='$outputLoc'
         local verbose='$verbose'
 
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
            bash dependency-diffusion.sh -c "$cmd" -t "$1" -p "$packageName" -a $minAge -s $minStars -v "$verbose" -o "$outputLoc"
         }  
      }
      '  > $diffusionPrexSh
   }
 
   if [[ -f "$instLocation/$diffusionPrexSh" ]]; then
      while true; do
         echo -e "\n[!] \"$diffusionPrexSh\" already found in $instLocation"
         read -p "[?] Do you want to overwrite it with the new options? (y/n): " yn
         case $yn in
            [Yy]* ) genNewPrex
               echo -e "\t\e[92m∟ Saved \e[96m$diffusionPrexSh\e[0m in $instLocation\e[0m\n"
               break
            ;;
            [Nn]* )  
               echo -e "\t\e[92m∟ Settings will NOT be changed. Using the exisiting \e[96m$diffusionPrexSh\e[0m in $instLocation\e[0m"
               break
            ;;
            * ) echo "Please answer yes or no.";;
         esac
      done
   else
      genNewPrex
      echo -e "\t\e[92m∟ Saved \e[96m$diffusionPrexSh\e[0m in $instLocation\e[0m"
   fi
 
}
 
for i in "${reqsArr[@]}"; do 
   reqCheck "$i"; 
done
 
while getopts "ha:s:v:o:" arg; do #Later add v: for verbose
   case $arg in
      h) printHelp && exit 1;;
      a) minAge=$OPTARG;;
      s) minStars=$OPTARG;;
      v) verbose=$OPTARG;;
      o) outputLoc=$OPTARG;;
   esac
done
 
logDirectory="${outputLoc%/*}"
logFile="${outputLoc##*/}"
 
if [[ "$#" -lt 6 ]]; then
   echo -e "\n\e[101m[!] Install FAILED:\e[0m MISSING ARGUMENT(s)\n">&2; 
   printHelp
   exit 1
elif [[ ! $minAge =~ $acceptRe ]] && [[ ! $minStars =~ $acceptRe ]]; then
   echo -e "\n\e[101m[!] Install FAILED:\e[0m wrong data type input">&2;
   echo -e "Please enter a whole number (ex: 0,1,2,3...) for the minimum age and stars\n" 
   exit 1
elif ! [[ -d "$logDirectory" ]] && [[ ! ${logFile: -5} == ".json" ]]; then
   echo -e "\n\e[101m[!] Install FAILED:\e[0m $logDirectory is not a valid directory to save your logs in!\n">&2;
   exit 1
elif [[ -z "$logFile" ]]; then
   echo "ERROR: NO FILE SPECIFIED TO SAVE LOGS"
   exit 1  
fi
 
printASCII
 
echo -e "\e[93m[+]\e[0m 1. Checking Requirements"
echo -e "\t\e[92m∟ Reqs Met: ${reqsMet[@]}\e[0m\n"
 
if ! [[ " ${reqsMet[*]} " == *" curl "* ]]; then
   printf "\nFAILED: cURL NOT FOUND! Failed to find curl. Please install it and try again: apt-get install curl\n\n"
   exit 1
fi
 
if ! [[ " ${reqsMet[*]} " == *" pip3 "* ]] && ! [[ " ${reqsMet[*]} " == *" pip "* ]]; then
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
      if ! [[ -f "$instLocation.bash-preexec.sh" ]]; then
         curl -s https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
         echo -e "\t\e[92m∟ Done!\e[0m Saved \e[96m.bash-preexec.sh\e[0m in $instLocation\e[0m\n"
      fi
 
      echo -e "\e[93m[+]\e[0m 4. Generating a pre-exec function to detect pip installs"
      makeDiffusionPrex
 
      echo -e "\n\e[93m[+]\e[0m 5. Adding \e[96mbash-preexec.sh\e[0m and \e[96m$diffusionPrexSh\e[0m function to .bashrc"
      if [[ $(grep -o "$bashConfSource" ~/.bashrc | wc -l) == 0 ]]; then
         # NOTE: MUST BE THE LAST ENTRY IN YOUR BASH CONFIG FILE (~/.bashrc, ~/.profile, ~/.bash_profile, etc).
         echo -e "# Dependency-Diffusion - MUST REMAIN ON THE LAST LINE in the bash config scripts\n$bashConfSource" >> .bashrc
         echo -e "\t\e[92m∟ Done!\e[0m this MUST be the last line in your bash config file"
      else
         echo -e "\t\e[92m∟ Already there.\e[0m this MUST be the last line in your bash config file"
      fi
 
      echo -e "\n\e[93m[+]\e[0m 6. Creating a log file for bad/ reported packages"
      logFile
 
      echo -e "\n\e[93m[+]\e[0m 7. Updating/ refreshing your bash configuration file"
      source ~/.bashrc
      echo -e "\t\e[92m∟ Done!\e[0m\n"
   else 
      echo "DID NOT FIND .bashrc in $instLocation, bye"
   fi
fi
