tool
extends Spatial

export var max_speed = 10.0
export var engine_power = 8.0
export var max_turning_speed = 30.0
export var turning_engine_power = 4.0
export var sight_radius = 50.0 setget set_sight_radius
export var targets_groups = ["red-team", "ships"]

onready var target_point = global_transform.origin setget set_target_point
onready var target_rotation = rotation.y

var target_node = null

func _ready():
	if Engine.editor_hint:
		set_physics_process(false)

func _physics_process(delta):
    if target_node != null:
        self.target_point = target_node.global_transform.origin
    global_transform.origin += (target_point - global_transform.origin) * min(max_speed * delta,  engine_power * delta)
    rotation.y += (target_rotation - rotation.y) * min(deg2rad(max_turning_speed) * delta, deg2rad(turning_engine_power) * delta)

func set_sight_radius(new_sight_radius):
    if has_node("Area"):
        $Area/CollisionShape.shape.radius = new_sight_radius
    sight_radius = new_sight_radius

func set_target_point(new_target_point):
    target_point = new_target_point
    target_rotation = Vector2(global_transform.origin.x, global_transform.origin.z).angle_to_point(Vector2(target_point.x, target_point.z))


func _on_Area_area_entered(area):
    if is_in_groups(area, targets_groups):
        target_node = area

func fire_weapons():
    for n in get_children():
        if n.is_in_group("weapons"):
            n.fire_at(target_point)

func is_in_groups(n, groups) -> bool:
    for g in groups:
        if not n.is_in_group(g):
            return false
    return true