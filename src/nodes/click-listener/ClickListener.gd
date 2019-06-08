extends RayCast

class_name ClickListener

signal somebody_clicked(click_listener)

const CAST_DISTANCE = 10000

func _input(event):
	if event.is_action_pressed("g_select"):
		var camera: Camera = get_viewport().get_camera()
		translation = camera.project_ray_origin(get_viewport().get_mouse_position())
		cast_to = camera.project_ray_normal(get_viewport().get_mouse_position()) * CAST_DISTANCE
		force_raycast_update()
		if is_colliding():
			var collider = get_collider()
			emit_signal("somebody_clicked", self, collider)
			collider.emit_signal("clicked", self)
		else:
			emit_signal("somebody_clicked", self, null)