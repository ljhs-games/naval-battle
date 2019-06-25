extends RigidBody

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

func _input_event(_camera, event, _click_position, _click_normal, _shape_idx):
#	if shape_idx == shadp
#	print("clicked!")
	if event.is_action_pressed("g_select"):
		emit_signal("clicked")
		print("clicked!")

# warning-ignore:unused_argument
func somebody_new():
	print("Battle positions!")

func set_selected(new_selected):
	var target_mesh = $PlaceholderShip/PlaceholderShip
	if not selected:
		if new_selected:
			print("selecting")
			base_material = target_mesh.get_surface_material(0)
			target_mesh.set_surface_material(0, selected_material)
#			target_mesh.get_surface_material(0).next_pass = base_material
			selected_material.next_pass = base_material
	if new_selected == false:
			print("de selecting")
			target_mesh.set_surface_material(0, base_material)
#			target_mesh.get_surface_material(0).next_pass = null
	selected = new_selected