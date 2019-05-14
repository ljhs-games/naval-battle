tool
extends Spatial

export (NodePath) var ocean_path setget set_ocean_path

onready var ocean_inst = get_node(ocean_path) as ocean



func set_ocean_path(new_ocean_path):
	ocean_path = new_ocean_path
	if has_node(new_ocean_path):
		ocean_inst = get_node(new_ocean_path)

func _process(delta):
	if ocean_inst != null:
		translation = ocean_inst.get_displace(Vector2(translation.x, translation.z))