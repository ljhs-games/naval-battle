extends Spatial

export var min_force = -100
export var max_force = 200
export var min_torque = -500.0
export var max_torque = 500.0
export var velocity_pid_parameters: Vector3 = Vector3(1, 1, 1)
export var angular_velocity_pid_parameters: Vector3 = Vector3(1, 1, 1)

onready var velocity_pid: PID = PID.new()
onready var angular_velocity_pid: PID = PID.new()


var target_rotation = 270.0 setget set_target_rotation
var target_angular_velocity = 10.0
var target_velocity = 0.0
var target_basis_x = Vector3(1, 0, 0)

func _ready():
	self.target_rotation = target_rotation
	velocity_pid.absorb_parameters(velocity_pid_parameters)
	angular_velocity_pid.absorb_parameters(angular_velocity_pid_parameters)

func integrate_parent_forces(parent: RigidBody, state: PhysicsDirectBodyState):
	velocity_pid.update(target_velocity - get_velocity(state), state.step)
	angular_velocity_pid.update(target_angular_velocity - state.angular_velocity.y, state.step)


	state.add_torque(Vector3(0, clamp(angular_velocity_pid.output, min_torque, max_torque), 0))
	state.add_central_force(state.transform.basis.x * clamp(velocity_pid.output, min_force, max_force))
	# print(clamp(angular_velocity_pid.output, min_torque, max_torque))
	print(state.angular_velocity.y)
	# print(rad2deg(get_angle_error(state)))

func get_velocity(state: PhysicsDirectBodyState) -> float:
	return state.linear_velocity.project(state.transform.basis.x).length()

func set_target_rotation(in_rotation: float):
	target_rotation = in_rotation
	target_basis_x = Vector3(1, 0, 0).rotated(Vector3(0, 1, 0), deg2rad(in_rotation))

func get_angle_error(state: PhysicsDirectBodyState) -> float:
	return state.transform.basis.x.angle_to(target_basis_x)