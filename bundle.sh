#!/bin/bash

set -e

GAME_EXECUTABLE_NAME="naval-battle"
MAC_APP_FOLDERNAME="Naval Battle.app"
PLATFORMS=( mac linux windows )
#GAME_VERSION_FILE="buildnumber.txt"

EXPORT_FOLDER="$(readlink -f exports)"
SRC_FOLDER="$(readlink -f src)"

# Guide through exporting game 
check_for() {
    echo "Checking for $1 ..."
    if ! [ "$(command -v $1)" ]; then echo "$1 not found! Exiting ..."
        exit 1
    fi
}

find_dir() {
    echo "Checking for $1 directory ..."
    if ! [ -d "$1" ]; then
        echo "$1 directory not found! Exiting ..."
        exit 1
    fi
}

check_for "xclip"
check_for "zip"
check_for "rm"
check_for "pwd"
check_for "godot-headless"
check_for "butler"

find_dir "$EXPORT_FOLDER"
find_dir "$SRC_FOLDER"

echo "Ensure version number is incremented using provided script ..."
read -n1 -s

#echo "Please export game to path in clipboard, then press any key to continue ..."
#read -n1 -s

#read -p "Game Executable Name   : " GAME_NAME

#read -p "Export Type            : " EXPORT_TYPE

#read -p "Version                : " GAME_VERSION
#GAME_VERSION=$(<"$GAME_VERSION_FILE")
GIT_VERSION="$(git describe --abbrev=0)"
GAME_VERSION="${GIT_VERSION:1}"

export_game() {
	echo "Deleting $EXPORT_FOLDER/ ..."
	rm -r $EXPORT_FOLDER
	echo "Creating $EXPORT_FOLDER/ ..."
	mkdir "$EXPORT_FOLDER"
	echo "Creating .gitkeep in $EXPORT_FOLDER/ ..."
	touch "$EXPORT_FOLDER/.gitkeep"

	if [ "$1" == "windows" ]; then
		GAME_NAME="${GAME_EXECUTABLE_NAME}.exe"
	else
		GAME_NAME="$GAME_EXECUTABLE_NAME"
	fi



	echo "Exporting $GAME_NAME v$GAME_VERSION for $1..."
	cd "$SRC_FOLDER"
	godot-headless --export "$1" "$EXPORT_FOLDER/$GAME_NAME"
	#zip "${GAME_NAME}-${1}v${GAME_VERSION}.zip" 

	if [ "$1" == "mac" ]; then
		cd "$EXPORT_FOLDER"
		unzip "$GAME_NAME"
		butler push "$MAC_APP_FOLDERNAME" "ljhsgames/naval-battle:$1" --userversion "$GAME_VERSION"
	else
		butler push "$EXPORT_FOLDER" "ljhsgames/naval-battle:$1" --userversion "$GAME_VERSION"
	fi

}

for i in "${PLATFORMS[@]}"
do
	export_game "$i"
done
echo "Done"
