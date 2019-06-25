tool
extends MultiMeshInstance

export var instance_count = 4
export var tile_size = 16
export var update_tiles = false setget set_update_tiles

var camera

func _ready():
	camera = get_node("/root").get_camera()
	if Engine.editor_hint:
		set_process(false)
	place_tiles()

func _process(_delta):
	translation = Vector3(camera.global_transform.origin.x, translation.y, camera.global_transform.origin.z)

func place_tiles():
	self.multimesh.instance_count = instance_count
	for i in range(instance_count):
		var position = Transform()
		var position_2d = get_next_position(i)*tile_size
		position = position.translated(Vector3(position_2d.x, 0, position_2d.y))
		multimesh.set_instance_transform(i, position)

func set_update_tiles(new_update_tiles):
	update_tiles = new_update_tiles
	update_tiles = false
	place_tiles()

func get_next_position(n) -> Vector2:
	var k = ceil((sqrt(n)-1)/2)
	var t = 2*k + 1
	var m = pow(t, 2)
	t = t-1
	if n >= m - t:
		return Vector2(k - (m - n), -k)
	else:
		m = m - t
	if n >= m - t:
		return Vector2(-k, -k+(m-n))
	else:
		m = m - t
	if n >= m - t:
		return Vector2(-k+(m-n),k)
	else:
		return Vector2(k, k-(m-n-t))