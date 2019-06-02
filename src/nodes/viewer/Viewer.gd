extends Spatial

enum ZOOM_STATE { zoom_in, zoom_out, stationary }

export var smoothing = 8.0
export var rotational_smoothing = 10.0
export var pan_speed = 1.5
export var zoom_speed = 60.0
export var min_camera_height = 35.0
export var rotational_speed = 0.002

onready var target_transform: Transform = transform
onready var base_transform: Transform = transform
onready var target_camera_transform: Transform = $Camera.transform
onready var base_camera_transform: Transform = $Camera.transform

var g_pan_input: String = "g_pan"
var look_vector: Vector2 = Vector2()
var cur_zoom_state: int = ZOOM_STATE.stationary
var reversed = 1

func _ready():
	if Settings.get_setting("touchpad_controls") == true:
		g_pan_input = "g_pan_touchpad"
	set_physics_process(true)
	set_process_input(true)
	transform.basis = Basis()

func _physics_process(delta):
	match cur_zoom_state:
		ZOOM_STATE.zoom_in:
			target_camera_transform.origin += get_zoom_direction() * -zoom_speed * reversed
		ZOOM_STATE.zoom_out:
			target_camera_transform.origin += get_zoom_direction() * zoom_speed * reversed


	transform.origin += (target_transform.origin - transform.origin) * smoothing * delta
	$Camera.transform.origin += (target_camera_transform.origin - $Camera.transform.origin) * smoothing * delta
	var new_camera_pos = get_camera_pos()
	if new_camera_pos.y <= min_camera_height:
		if target_transform.basis.y.y < 0.0: # if upside down
			target_transform.basis = target_transform.basis.rotated(target_transform.basis.z, PI)
			target_transform.origin.y = min_camera_height
			target_transform = target_transform.orthonormalized()
		elif target_transform.basis.z.y < 0.0: # if rotating camera downard
			target_transform.basis = target_transform.basis.rotated(target_transform.basis.x, altitude_angle(target_transform.basis.z))
			target_transform = target_transform.orthonormalized()
		target_transform.origin.y += min_camera_height - new_camera_pos.y
	if (target_camera_transform.basis.z.dot(target_transform.origin - target_camera_transform.origin)) > 0: # if zoomed in so camera not facing center
		target_camera_transform.basis = target_camera_transform.basis.rotated(Vector3(0, 1, 0), PI)
		reversed = -reversed
	

	transform.basis = transform.basis.slerp(target_transform.basis, rotational_smoothing * delta)
	$Camera.transform.basis = $Camera.transform.basis.slerp(target_camera_transform.basis, rotational_smoothing * delta)
	transform = transform.orthonormalized()

func _input(event):
	# pan movement with motion
	if event is InputEventMouseMotion:
		if Input.is_action_pressed(g_pan_input):
			if Input.is_action_pressed("g_pan_forward"):
				target_transform.origin += Vector3(event.relative.x*reversed, 0, event.relative.y*reversed).rotated(Vector3(0, 1, 0), rotation.y)*pan_speed
			else:
				target_transform.origin += Vector3(event.relative.x*reversed, -event.relative.y, 0.0).rotated(Vector3(0, 1, 0), rotation.y)*pan_speed
		if Input.is_action_pressed("g_rotate_about"):
			target_transform.basis = target_transform.basis.rotated(Vector3(0, 1, 0), -event.relative.x*rotational_speed)
			target_transform.basis = target_transform.basis.rotated(target_transform.basis.x, -event.relative.y*rotational_speed*reversed)

	# rotate about point with motion
	# show and hide mouse when panning
	elif event.is_action_pressed(g_pan_input):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_released(g_pan_input):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("g_rotate_about"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_released("g_rotate_about"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("g_zoom_in"):
		target_camera_transform.origin += get_zoom_direction() * -zoom_speed * reversed
		cur_zoom_state = ZOOM_STATE.zoom_in
	elif event.is_action_pressed("g_zoom_out"):
		target_camera_transform.origin += get_zoom_direction() * zoom_speed * reversed
		cur_zoom_state = ZOOM_STATE.zoom_out
	elif event.is_action_released("g_zoom_in") or event.is_action_released("g_zoom_out"):
		cur_zoom_state = ZOOM_STATE.stationary
	elif event.is_action_pressed("g_cam_reset"):
		target_transform = base_transform
		target_camera_transform = base_camera_transform
		look_vector = Vector2()

func get_camera_pos() -> Vector3:
	return $Camera.global_transform.origin

func get_zoom_direction() -> Vector3:
	return Vector3(0, 0, 1)

func altitude_angle(A: Vector3) -> float:
	# taken from https://stackoverflow.com/questions/12229950/the-x-angle-between-two-3d-vectors
	var B := Vector3(1, 0, 1)
	var x = A.x - B.x
	var y = A.y - B.y
	var z = A.z - B.z
	return atan2(y, sqrt(x*x + z*z))