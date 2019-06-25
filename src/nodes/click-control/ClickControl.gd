extends Spatial

var click_inside_parent = false

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("clicked", self, "_on_parent_clicked")

func _on_parent_clicked():
	click_inside_parent = true
	if get_parent().selected:
		get_node("/root/Main/Viewer").target_node = get_parent()
	else:
		get_parent().selected = true

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
	elif event.is_action_released("g_select"):
		if click_inside_parent == false and get_parent().selected:
			get_parent().selected = false
		click_inside_parent = false