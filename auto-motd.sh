#!/bin/bash

# Make sure script is executed as root
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

function confirm {
  while true; do
    read -p "Do you want to continue (y/N)? " choice
    case "$choice" in 
      y|Y ) break;;
      n|N ) exit 0;;
      "" ) exit 0;;
      * ) echo "Invalid choice. Please specify \"y\" or \"n\".";;
    esac
  done
}

depList=("figlet")
depsToInstall=()

for dep in $depList; do
  if ! command -v $dep 2>&1 >/dev/null; then
    $depsToInstall+=($dep)
  fi
done

if [ ${#depsToInstall[@]} -neq 0 ]; then
  echo "This program will install the following dependencies: $depsToInstall"
  confirm
  apt update && {
    for dep in $depsToInstall; do
      #apt install $dep -y
      echo "installing $dep"
    done
  }
fi
