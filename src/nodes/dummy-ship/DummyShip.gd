extends Spatial

export (NodePath) var ocean_path

onready var ocean_inst = get_node(ocean_path) as ocean

func _process(delta):
	if ocean_inst != null:
		translation = ocean_inst.get_displace(Vector2(global_transform.origin.x, global_transform.origin.z)) + Vector3(0.0, 10.0, 0.0)