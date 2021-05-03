![Repo Header](/imgs/header.png)

# Dependency-Diffusion
Logs suspicious pip package installs. 
- This was done to sharpen my bash scripting skills in preparation for an internship this summer. 100% pure shell, with the least amount of dependencies possible (only 1 used, @rcaloras's awesome [bash-preexec](https://github.com/rcaloras/bash-preexec)).
  - I typically use python for everything and this would have been much easier with python, but it is better to improve in other areas. 
- Why not "defusion?"
  - It logs specific installs, and does **not** defuse an install as the original intention was.

## What?
- Logs pip package installs that do not meet certain options set by you, such as minimum age and stars the repo has, sudo installs, and if a package is not on GitHub. 
- Installs that do not meet your options/ preferences are logged in a JSON formatted file.

## Why? 
- To help improve your IR efforts and you can never go wrong with more logs. 
- The idea was based on Alex Birsan's [Dependency Confusion Supply Chain Attack](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)
  - The ideal solution would have been a blacklist/ whitelist to stop an install, and I might give it a shot with python later on. 
- Awesome ASCII, because c'mon!

### Log Suspicious pip Installs
![Json log](/imgs/json.png)

### User Warning
![Age and Stars reqs not met](/imgs/ageStars.png)
![Sudo Install warning](/imgs/sudoInstall.png)

### Get Package Info
![Verbose Mode](/imgs/verbose.png)

## Maintenance
- The bash-preexec and support scripts added to the .bashrc at step 5 must remain as the last line entry in the bash config file. 
  - You can add anything before it, just make sure it's the last entry. This is from using the [bash-preexec](https://github.com/rcaloras/bash-preexec) function. 
  - What is awesome is you can probably use the preexec function for zsh, which would be a wiser choice over bash...
- If you want to change your settings (min age/ stars, etc.), you can edit the `.dependency-diffusion.sh` created at step 4. Alternatively, you can just run a a new ./setup.sh

## Installation
- Move `dependency-diffusion.sh` to the user's home directory, then run ./setup.sh
- The setup script will generate a custom bash-preexec function based on the options you select. 
  - You can see an example of what this looks like in `preexec-example.sh` 
If everything goes smoothly your setup will look something like this...
![Setup](/imgs/setupScreen.png)

## Usage
```
Usage: setup.sh [-h | -a -s -o]
options:
	-h   Print the help page.
	-a   Set the minimum age requirement of a package in days.
	-s   Set the minimum stars requirement for a package's GitHub repo.
	-o   Creates a log file for all reported packages, JSON format.
	-v   Verbose mode. Only recommended for debugging. [-v true] to enable. Prints 
		PyPI & GitHub package URL and their stats before every package install.

# Minimum age 90, stars 29, anything less will be logged
Example: bash setup.sh -a 90 -s 29 -o bad_package_log.json 
Example: ./setup.sh -a 90 -s 29 -v true -o bad_package_log.json

```
