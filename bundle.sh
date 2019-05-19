#!/bin/bash

set -e

GAME_EXECUTABLE_NAME="naval-battle"
MAC_APP_FOLDERNAME="Naval Battle.app"
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
check_for "godot"
check_for "butler"

find_dir "$EXPORT_FOLDER"
find_dir "$SRC_FOLDER"

echo "Deleting $EXPORT_FOLDER/ ..."
rm -r $EXPORT_FOLDER
echo "Creating $EXPORT_FOLDER/ ..."
mkdir "$EXPORT_FOLDER"
echo "Creating .gitkeep in $EXPORT_FOLDER/ ..."
touch "$EXPORT_FOLDER/.gitkeep"
cd "$EXPORT_FOLDER"
echo "Copying $EXPORT_FOLDER path to clipboard ..."
pwd | xclip -selection c
cd ..
echo "Ensure version number is incremented in buildnumber.txt ..."
echo "Please ensure that Godot is only open to the project manager before exporting ..."
read -n1 -s

#echo "Please export game to path in clipboard, then press any key to continue ..."
#read -n1 -s

#read -p "Game Executable Name   : " GAME_NAME

read -p "Export Type            : " EXPORT_TYPE

#read -p "Version                : " GAME_VERSION
#GAME_VERSION=$(<"$GAME_VERSION_FILE")
GIT_VERSION="$(git describe --abbrev=0)"
GAME_VERSION="${GIT_VERSION:1}"

if [ "$EXPORT_TYPE" == "windows" ]; then
	GAME_NAME="${GAME_EXECUTABLE_NAME}.exe"
else
	GAME_NAME="$GAME_EXECUTABLE_NAME"
fi



echo "Exporting $GAME_NAME v$GAME_VERSION..."
cd "$SRC_FOLDER"
godot --export "$EXPORT_TYPE" "$EXPORT_FOLDER/$GAME_NAME"
cd "$EXPORT_FOLDER"
#zip "${GAME_NAME}-${EXPORT_TYPE}v${GAME_VERSION}.zip" 

if [ "$EXPORT_TYPE" == "mac" ]; then
	unzip "$GAME_NAME"
	EXPORT_FOLDER="$MAC_APP_FOLDERNAME"
fi

butler push "$EXPORT_FOLDER" "ljhsgames/naval-battle:$EXPORT_TYPE" --userversion "$GAME_VERSION"
echo "Done"
