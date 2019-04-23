extends Spatial

export var lower_bound = 100.0
const pan_speed = 0.4

func _ready():
	set_process_input(true)

func translate_object_local(to_translate: Vector3):
	.translate_object_local(to_translate)
	if $Camera.global_transform.origin.y < lower_bound:
		.translate_object_local(-Vector3(0.0, to_translate.y, 0.0))

func _input(event):
	# pan movement with motion
	if event is InputEventMouseMotion and Input.is_action_pressed("g_pan"):
		translate_object_local(Vector3(event.relative.x, -event.relative.y, 0.0)*pan_speed)
	# show and hide mouse when panning
	elif event.is_action_pressed("g_pan"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_released("g_pan"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

