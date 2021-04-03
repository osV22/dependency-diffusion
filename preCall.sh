preexec() { 
 
	local minAge=20
	local minStars=20
 
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
       echo "x-x-x-x- PIP 5 CALLED" # testing, don't want to trigger an actual pip3 request
       requestCheck "3"
      ;;
   esac
 
   function requestCheck() {
      echo "Pip Version: pip $1"
      echo "Package Name: $packageName"
      bash reportPackage.sh -p "$packageName" -a $minAge -s $minStars
   }  
}