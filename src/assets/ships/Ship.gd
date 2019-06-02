extends RigidBody

export var buoyancy_constant = 1.0

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
	for c in get_children():
		if c.is_in_group("physical"):
			c.integrate_parent_forces(self, state)

# warning-ignore:unused_argument
func fire_at(target_node):
	print("Battle positions!")
	pass