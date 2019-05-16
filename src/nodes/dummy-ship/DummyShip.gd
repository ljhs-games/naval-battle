extends Spatial

export (NodePath) var ocean_path setget set_ocean_path

onready var ocean_inst = get_node(ocean_path) as ocean
var base_height: float

func set_ocean_path(new_ocean_path):
	ocean_path = new_ocean_path
	if has_node(new_ocean_path):
		ocean_inst = get_node(new_ocean_path)

func _ready():
	base_height = translation.y

func _process(_delta):
	if ocean_inst != null:
		translation = ocean_inst.get_displace(translation) + Vector3(0.0, base_height, 0.0)