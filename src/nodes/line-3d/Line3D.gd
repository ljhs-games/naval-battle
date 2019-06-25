extends ImmediateGeometry

export var line_color = Color() setget set_line_color
var target_position = Vector3() setget set_target_position

func _ready():
	set_as_toplevel(true)

func set_line_color(new_line_color):
	line_color = new_line_color
#	update_line()

func set_target_position(new_target_position):
	target_position = new_target_position
#	update_line()

func _process(_delta):
	update_line()

func update_line():
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	set_color(line_color)
	add_vertex(get_parent().global_transform.origin)
	add_vertex(target_position)
	end()