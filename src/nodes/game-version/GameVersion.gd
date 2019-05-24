extends Node

const gameversion_filename = "res://version.txt"

var gameversion_file: File = File.new()
var version: String

func _ready():
	if gameversion_file.file_exists(gameversion_filename):
		assert(gameversion_file.open(gameversion_filename, File.READ) == OK)
		version = gameversion_file.get_as_text()
		print("Gameversion file found, version: ", version)
	else:
		print(gameversion_filename, " not found, using DEVELOP version ...")
		version = "DEVELOP"

func get_version() -> String:
	return version

func get_version_hash() -> int:
	return get_version().hash()