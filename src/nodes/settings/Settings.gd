tool
extends Node

signal setting_changed(setting_string, new_val)

const setting_filename = "user://settings.json"

enum OCEAN_QUALITY { low, high }

var settings_file = File.new()

var _settings = {
	"audio": true,
	"ocean_quality": OCEAN_QUALITY.low
}

func _ready():
	assert(connect("tree_exiting", self, "_on_Settings_tree_exiting") == OK)
	assert(get_tree().connect("tree_changed", self, "_on_Settings_tree_changed") == OK)
	if settings_file.file_exists(setting_filename):
		settings_file.open(setting_filename, File.READ)
		print("settings file: ", settings_file.get_path_absolute())
		_settings = parse_json(settings_file.get_as_text())
		print(_settings)
	settings_file.close()

func _on_Settings_tree_changed():
	#print("Updating")
	for setting_name in _settings.keys():
		emit_signal("setting_changed", setting_name, _settings[setting_name])

func _on_Settings_tree_exiting():
	dump_settings()

func dump_settings():
	settings_file.open(setting_filename, File.WRITE)
	settings_file.store_string(to_json(_settings))
	settings_file.close()

func set_setting(setting_name, new_val):
	_settings[setting_name] = new_val
	emit_signal("setting_changed", setting_name, new_val)

func get_setting(setting_name: String):
	return _settings[setting_name]