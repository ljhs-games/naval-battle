extends Spatial

export var smoothing = 8.0
export var pan_speed = 1.0
export var zoom_speed = 35.0
export var min_camera_height = 35.0

onready var target_transform: Transform = transform
onready var base_transform: Transform = transform

var g_pan_input: String = "g_pan"

func _ready():
	if Settings.get_setting("touchpad_controls") == true:
		g_pan_input = "g_pan_touchpad"
	set_physics_process(true)
	set_process_input(true)

func _physics_process(delta):
	# smoothly interpolate translation
	# translation = (target_translation - translation) * smoothing * delta + translation
	transform.origin = (target_transform.origin - transform.origin) * smoothing * delta + translation
	var new_camera_pos = get_camera_pos()
#	print(new_camera_pos)
	if new_camera_pos.y <= min_camera_height:
		target_transform.origin.y += min_camera_height - new_camera_pos.y

func _input(event):
	# pan movement with motion
	if event is InputEventMouseMotion:
		if Input.is_action_pressed(g_pan_input):
			target_transform.origin += Vector3(event.relative.x, -event.relative.y, 0.0)*pan_speed

	# rotate about point with motion
	# show and hide mouse when panning
	elif event.is_action_pressed(g_pan_input):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_released(g_pan_input):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("g_zoom_in"):
		target_transform.origin += get_zoom_direction() * -zoom_speed
	elif event.is_action_pressed("g_zoom_out"):
		target_transform.origin += get_zoom_direction() * zoom_speed
	elif event.is_action_pressed("g_cam_reset"):
		target_transform = base_transform

func get_camera_pos() -> Vector3:
	return $Camera.global_transform.origin + (target_transform.origin - translation)

func get_zoom_direction() -> Vector3:
	var real_camera_pos = get_camera_pos()
	return (real_camera_pos - target_transform.origin).normalized()