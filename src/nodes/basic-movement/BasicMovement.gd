extends Spatial

class_name BasicMovement

export var min_force = -100
export var max_force = 200
export var min_torque = -1000
export var max_torque = 1000
export var position_pid_parameters: Vector3 = Vector3(1, 1, 1)
export var position_pid_min_output: float = 20.0
#export var position_min_distance = 200
export var angular_pid_parameters: Vector3 = Vector3(1, 1, 1)
export var angular_pid_min_output: float = 0.0

onready var position_pid: PID = PID.new()
onready var angular_pid: PID = PID.new()


var target_position = Vector3(0, 0, 0) setget set_target_position
var target_rotation = 0
var target_basis_x = Vector3(1, 0, 0) setget set_target_basis_x

func _ready():
	self.target_rotation = target_rotation # call setter
	position_pid.absorb_parameters(position_pid_parameters)
	position_pid.minimum_output = position_pid_min_output
	angular_pid.absorb_parameters(angular_pid_parameters)
	angular_pid.minimum_output = angular_pid_min_output

func integrate_parent_forces(_parent: RigidBody, state: PhysicsDirectBodyState):
	self.target_basis_x = (target_position - _parent.translation).normalized()
	angular_pid.update(get_angle_error(state), state.step)
#	print(target_position)
#	print(clamp(angular_pid.output, min_torque, max_torque))
	# print(get_angle_error(state))
	# print(rad2deg(parent.rotation.y))
#	print(Vector3(0, clamp(angular_pid.output, min_torque, max_torque), 0))
#	state.add_torque(Vector3(0, 1000, 0))
#	print(" ", get_angle_error(state), "	", _parent.rotation_degrees.y, "	", target_rotation)
	state.add_torque(Vector3(0, clamp(angular_pid.output, min_torque, max_torque), 0))
#	print(get_angle_error(state))
#	if(abs(get_angle_error(state)) < 5.0):
#		print(get_position_error(state))
#		var position_delta = (target_position - state.transform.origin).length()
#		if position_delta > position_min_distance:
#			state.add_central_force(state.transform.basis.x * max_force)
	position_pid.update(get_position_error(state), state.step)
	var position_output = clamp(lerp(position_pid.output, 0.0, clamp(abs(get_angle_error(state))/40.0, 0, 1)), min_force, max_force)
#	print(position_output, "	", position_pid.output)
	state.add_central_force(state.transform.basis.x * position_output)
	# print(clamp(angular_velocity_pid.output, min_torque, max_torque))
	# print(clamp(position_pid.output, min_force, max_force))
	# print(get_position_error(state))
	# print(rad2deg(get_angle_error(state)))

func set_target_position(new_position):
	target_position = new_position
	position_pid.clear()
	$Line3D.target_position = new_position
	var parent = get_parent()
#	self.target_rotation = rad2deg(position_2d.angle_to_point(target_2d_position) +  PI)
	self.target_basis_x = (new_position - parent.translation).normalized()

func get_position_error(state: PhysicsDirectBodyState) -> float:
#	print(get_parent().transform.basis.x)
	return (target_position - state.transform.origin).length() * sign(state.transform.basis.x.dot(target_position - state.transform.origin))

func get_velocity(state: PhysicsDirectBodyState) -> float:
	return state.linear_velocity.project(state.transform.basis.x).length()

func set_target_basis_x(in_target_basis_x: Vector3):
	target_basis_x = in_target_basis_x
	target_rotation = rad2deg(Vector2(target_basis_x.x, target_basis_x.z).angle())

func get_angle_error(state: PhysicsDirectBodyState) -> float:
	return rad2deg(state.transform.basis.x.angle_to(target_basis_x))*get_angle_sign(state)

func get_angle_sign(state: PhysicsDirectBodyState) -> float:
	return -sign(Vector2(state.transform.basis.x.x, state.transform.basis.x.z).cross(Vector2(target_basis_x.x, target_basis_x.z)))