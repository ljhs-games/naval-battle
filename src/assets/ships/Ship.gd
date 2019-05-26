extends RigidBody

export (NodePath) var ocean_path setget set_ocean_path
export var buoyancy_constant = 1.0

onready var ocean_inst = get_node(ocean_path) as ocean
onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
var base_height: float

func set_ocean_path(new_ocean_path):
	ocean_path = new_ocean_path
	if has_node(new_ocean_path):
		ocean_inst = get_node(new_ocean_path)

func _ready():
	base_height = translation.y

func _integrate_forces(state: PhysicsDirectBodyState):
	var ocean_position
	var archimedes_force = 0.0
	if ocean_inst != null:
		ocean_position = ocean_inst.get_displace(translation)
	else:
		ocean_position = Vector3(translation.x, base_height, translation.z)
	archimedes_force = base_height - translation.y
	# archimedes_force = base_height - ocean_position.y
	if archimedes_force < 0.0:
		archimedes_force = 0.0
	else:
		archimedes_force = sqrt(archimedes_force)
	state.add_central_force(Vector3(0.0, archimedes_force*buoyancy_constant, 0.0))