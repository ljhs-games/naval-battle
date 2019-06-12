extends RigidBody

# warning-ignore:unused_signal
signal clicked

export var buoyancy_constant = 1.0
export (Material) var selected_material

var base_height: float
var selected = false setget set_selected
var base_material = null

func _ready():
	base_height = translation.y

func _integrate_forces(state: PhysicsDirectBodyState):
	# sadly floating boats broke with linear damp...
	var archimedes_force = base_height - translation.y
	# archimedes_force = base_height - ocean_position.y
	if archimedes_force < 0.0:
		archimedes_force = 0.0
	else:
		archimedes_force = sqrt(archimedes_force)
	state.add_central_force(Vector3(0.0, archimedes_force*buoyancy_constant, 0.0))
#	print(base_height - translation.y)
	for c in get_children():
		if c.is_in_group("physical"):
			c.integrate_parent_forces(self, state)

# warning-ignore:unused_argument
func somebody_new():
	print("Battle positions!")

func set_selected(new_selected):
	if not selected:
		if new_selected:
			print("selecting")
			base_material = $PlaceholderShip.get_surface_material(0)
			$PlaceholderShip.set_surface_material(0, selected_material)
			$PlaceholderShip.get_surface_material(0).next_pass = base_material
	if new_selected == false:
			print("de selecting")
			$PlaceholderShip.set_surface_material(0, base_material)
			$PlaceholderShip.get_surface_material(0).next_pass = null
	selected = new_selected