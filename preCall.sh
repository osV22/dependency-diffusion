preexec() { 
    
   local cmd=${1,,}
   echo "Command Entered: $cmd"
   
   cmdArr=($cmd)
   local packageName="${cmdArr[@]:2}"
 
   case "$cmd" in 
     "pip install "[0-9a-z]*)
       # Pip Procedure
       echo "pip install------------"
       requestCheck
      ;;
     "pip5 install "[0-9a-z]*) # Will change to pip3 later 
       # Pip3 Procedure 
       echo "pip3 intall------------"
       requestCheck "3" 
      ;;
   esac
 
   function requestCheck() {
      echo "pip Version: pip $1"
      echo "Package Name: $packageName"
   }
}
 
