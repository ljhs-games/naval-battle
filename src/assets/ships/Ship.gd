extends RigidBody

export var buoyancy_constant = 1.0

onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
var base_height: float

func _ready():
	base_height = translation.y

func _integrate_forces(state: PhysicsDirectBodyState):
	var archimedes_force = base_height - translation.y
	# archimedes_force = base_height - ocean_position.y
	if archimedes_force < 0.0:
		archimedes_force = 0.0
	else:
		archimedes_force = sqrt(archimedes_force)
	state.add_central_force(Vector3(0.0, archimedes_force*buoyancy_constant, 0.0))