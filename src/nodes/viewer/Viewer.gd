extends Spatial

export var smoothing = 8.0
export var pan_speed = 1.0
export var zoom_speed = 35.0

onready var target_translation: Vector3 = translation

func _ready():
	set_physics_process(true)
	set_process_input(true)

func _physics_process(delta):
	# smoothly interpolate translation
	translation = (target_translation - translation) * smoothing * delta + translation

func _input(event):
	# pan movement with motion
	if event is InputEventMouseMotion and Input.is_action_pressed("g_pan"):
		target_translation += Vector3(event.relative.x, -event.relative.y, 0.0)*pan_speed
	# show and hide mouse when panning
	elif event.is_action_pressed("g_pan"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_released("g_pan"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("g_zoom_in"):
		target_translation += get_zoom_direction() * -zoom_speed
	elif event.is_action_pressed("g_zoom_out"):
		target_translation += get_zoom_direction() * zoom_speed

func get_zoom_direction():
	var real_camera_pos = $Camera.global_transform.origin + (target_translation - translation)
	return (real_camera_pos - target_translation).normalized()