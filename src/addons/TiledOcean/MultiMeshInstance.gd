tool
extends MultiMeshInstance

export var instance_count = 4
export var tile_size = 16
export var update_tiles = false setget set_update_tiles

func _ready():
	place_tiles()

func place_tiles():
	multimesh.instance_count = instance_count
	for i in range(instance_count):
		var position = Transform()
		var position_2d = get_next_position(i)*tile_size
		position = position.translated(Vector3(position_2d.x, 0, position_2d.y))
		multimesh.set_instance_transform(i, position)

func set_update_tiles(new_update_tiles):
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