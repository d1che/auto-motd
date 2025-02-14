#!/bin/bash

function confirm {
  while true; do
    read -p "$1 (y/N)? " choice
    case "$choice" in 
      y|Y ) return 0;;
      n|N ) return 1;;
      "" ) return 1;;
      * ) echo "Invalid choice. Please specify \"y\" or \"n\".";;
    esac
  done
}

depList=("figlet")
depsToInstall=()

for dep in $depList; do
  if ! command -v $dep 2>&1 >/dev/null; then
    depsToInstall+=($dep)
  fi
done

if [ ${#depsToInstall[@]} -gt 0 ]; then
  echo "This program will install the following dependencies: $depsToInstall"
  confirm "Do you want to continue?" && {
    echo "updating package lists"
    apt update > /dev/null 2>&1 && {
      for dep in $depsToInstall; do
        echo "installing $dep"
        apt install $dep -y > /dev/null 2>&1
      done
    }
  } || exit 0
fi

echo "Please enter a primary title that will be displayed as an ascii text banner"
echo "generated by figlet."

read -p "Primary title: " title
confirm "Are you sure you want the primary title to be \"$title\"?" || {
  exit 0
}

echo "Please enter a figlet font name for the primary title of the motd message."
echo "A complete list can be found here: http://www.figlet.org/fontdb.cgi"

while true; do
  read -p "Font name: " font
  font=$(echo $font | tr '[:upper:]' '[:lower:]')
  wget -S --spider http://www.figlet.org/fonts/$font.flf 2>&1 | grep -q '200 OK' && {
    break
  } || {
    echo "\"$font\" is not a valid figlet font, please try again"
  }
done

wget -O $font.flf http://www.figlet.org/fonts/$font.flf > /dev/null 2>&1
echo -e "\n" > motd
figlet "$title" -f $font >> motd

# add space in front of each line
sed -i -e 's/^/   /' motd

info="\t$(hostname).$(hostname -d) @ $(hostname -I)"

echo >> motd
echo -e $info >> motd
echo >> motd

clear
echo "MOTD PREVIEW:"
cat motd
confirm "Are you sure you want to set this as your new motd?" && {
  echo "setting up new motd as /etc/motd"
  cp motd /etc
}

echo "removing temp files"
rm $font.flf
rm motd

echo "uninstalling figlet"
apt remove figlet -y > /dev/null 2>&1