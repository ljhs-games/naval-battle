#!/bin/bash

set -e

GAME_EXECUTABLE_NAME="naval-battle"
MAC_APP_FOLDERNAME="Naval Battle.app"
EDITOR_SETTINGS_PATH="$(readlink -f ~/.config/godot/editor_settings-3.tres)" # so can fix clearing settings on export
PLATFORMS=( linux mac windows )

EXPORT_FOLDER="$(readlink -f exports)"
SRC_FOLDER="$(readlink -f src)"

GAME_VERSION_FILE="$SRC_FOLDER/version.txt"

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

find_file() {
	echo "Checking for $1 file ..."
	if ! test -f "$1"; then
		echo "$1 file not found! Exiting ..."
		exit 1
	fi
}

check_for "zip"
check_for "rm"
check_for "pwd"
check_for "godot-headless"
check_for "butler"

find_dir "$EXPORT_FOLDER"
find_dir "$SRC_FOLDER"

find_file "$EDITOR_SETTINGS_PATH"

echo "Ensure version number is incremented using provided script ..."
read -n1 -s

echo "Please quit all instances of Godot ..."
read -n1 -s

echo "Caching editor settings ..."
TEMP_EDITOR_SETTINGS_CACHE="$(mktemp /tmp/bundle.sh.XXXXXX)"
cp "$EDITOR_SETTINGS_PATH" "$TEMP_EDITOR_SETTINGS_CACHE"

#echo "Please export game to path in clipboard, then press any key to continue ..."
#read -n1 -s

#read -p "Game Executable Name   : " GAME_NAME

#read -p "Export Type            : " EXPORT_TYPE

#read -p "Version                : " GAME_VERSION
#GAME_VERSION=$(<"$GAME_VERSION_FILE")
GIT_VERSION="$(git describe --abbrev=0)"
GAME_VERSION="${GIT_VERSION:1}"

echo "$GAME_VERSION" > "$GAME_VERSION_FILE"

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
	godot-headless --export "$1" "$EXPORT_FOLDER/$GAME_NAME" # must be debug to see version.txt?
	#zip "${GAME_NAME}-${1}v${GAME_VERSION}.zip" 

	if [ "$1" == "mac" ]; then
		cd "$EXPORT_FOLDER"
		unzip "$GAME_NAME"
		butler push "$MAC_APP_FOLDERNAME" "ljhsgames/naval-battle:$1" --userversion "$GAME_VERSION"
	else
		echo
		butler push "$EXPORT_FOLDER" "ljhsgames/naval-battle:$1" --userversion "$GAME_VERSION"
	fi

	echo "Replacing editor settings ..."
	cp "$TEMP_EDITOR_SETTINGS_CACHE" "$EDITOR_SETTINGS_PATH"
}

for i in "${PLATFORMS[@]}"
do
	export_game "$i"
done

rm "$GAME_VERSION_FILE"

echo "Done"
