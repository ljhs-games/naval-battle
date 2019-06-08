extends Spatial

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("clicked", self, "_on_parent_clicked")

func _on_parent_clicked(click_listener: ClickListener):
	get_parent().selected = true
# warning-ignore:return_value_discarded
	if not click_listener.is_connected("somebody_clicked", self, "_on_somebody_clicked"):
		click_listener.connect("somebody_clicked", self, "_on_somebody_clicked")

func _on_somebody_clicked(click_listener: ClickListener, object_clicked):
	if object_clicked != get_parent():
			get_parent().selected = false
			click_listener.disconnect("somebody_clicked", self, "_on_somebody_clicked")
	else:
		get_node("/root/Main/Viewer").target_node = get_parent()

func _input(event):
	if event.is_action_pressed("g_goto") and get_parent().selected:
		var travel_plane = Plane(Vector3(0, 1, 0), 0)
		var camera: Camera = get_viewport().get_camera()
		var intersect_result = travel_plane.intersects_ray(camera.project_ray_origin(get_viewport().get_mouse_position()), camera.project_ray_normal(get_viewport().get_mouse_position()))
		if intersect_result == null:
			print("no intersecetion :(") # TODO add noise
		else:
			print("Going to: ", intersect_result)
			get_node("../BasicMovement").target_position = intersect_result