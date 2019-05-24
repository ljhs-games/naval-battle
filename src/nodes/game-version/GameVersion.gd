extends Node

const gameversion_filename = "res://version.txt"

var gameversion_file: File = File.new()
var version_found = false

func _ready():
	if gameversion_file.file_exists(gameversion_filename):
		if gameversion_file.open(gameversion_filename, File.READ) == OK:
			version_found = true
			print("Gameversion file found!")
		else:
			printerr("Failed to open gameversion_file ...")
	else:
		print(gameversion_filename, " not found, using DEVELOP version ...")

func get_version() -> String:
	if version_found:
		return gameversion_file.get_as_text()
	return "DEVELOP"

func get_version_hash() -> int:
	return get_version().hash()