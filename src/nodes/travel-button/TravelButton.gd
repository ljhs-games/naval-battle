extends Button

# warning-ignore:unused_class_variable
export (String, FILE, "*.tscn") var target_scene



func _on_TravelButton_pressed():
	var travel_state = get_tree().change_scene(target_scene)
	assert(travel_state == OK)