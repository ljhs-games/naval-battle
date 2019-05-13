extends Spatial

export (NodePath) var ocean_path

onready var ocean_inst = get_node(ocean_path) as ocean

func _process(delta):
	if ocean_inst != null:
#		print(ocean_inst.get_displace(translation))
		translation = ocean_inst.get_displace(Vector2(translation.x, translation.z)) + Vector3(0.0, 10.0, 0.0)