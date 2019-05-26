tool
extends Spatial

export var max_speed = 500.0
export var engine_acceleration = 20.0
export var max_turning_speed = 30.0
export var turning_engine_acceleration = 0.5
export var acceptable_distance = 1.0
export var sight_radius = 50.0 setget set_sight_radius
export var target_required_groups = ["red-team", "ships"]
export var initial_target_point_offset = Vector3(2000, 0, 0) # move forward

onready var target_point = global_transform.origin setget set_target_point
onready var target_rotation = rotation.y

var target_node = null

var accel = 0.0 # direction is towards target_point
var angular_accel = 0.0
var velocity = 0.0
var angular_velocity = 0.0


func _ready():
    if Engine.editor_hint:
        set_physics_process(false)
    self.target_point = initial_target_point_offset + target_point

func _physics_process(delta):
    if target_node != null:
        self.target_point = target_node.global_transform.origin
    var error_length = get_error_vector().length() 
    if accel >= 0.0 and error_length <= -(velocity*velocity)/(2*-accel + 0.00001):
        accel = -accel
    elif accel < 0.0 and error_length <= acceptable_distance:
        accel = 0.0
    elif accel == 0.0 and error_length >= acceptable_distance:
        accel = engine_acceleration
    velocity += delta * accel
    velocity = min(velocity, max_speed)
    global_transform.origin += delta * velocity * get_direction_vector()
    rotation.y += delta * angular_velocity
    # global_transform.origin += slowest_speed(target_point - global_transform.origin, max_speed, engine_power, delta)
    # rotation.y += slowest_speed(target_rotation - rotation.y, deg2rad(max_turning_speed), deg2rad(turning_engine_power), delta)
    # global_transform.origin += (target_point - global_transform.origin) * min(max_speed * delta,  engine_power * delta)
    # rotation.y += (target_rotation - rotation.y) * min(deg2rad(max_turning_speed) * delta, deg2rad(turning_engine_power) * delta)

func set_sight_radius(new_sight_radius):
    if has_node("TargetArea"):
        $TargetArea/CollisionShape.shape.radius = new_sight_radius
    sight_radius = new_sight_radius

func set_target_point(new_target_point):
    target_point = new_target_point
    target_rotation = Vector2(global_transform.origin.x, global_transform.origin.z).angle_to_point(Vector2(target_point.x, target_point.z))


func _on_Area_area_entered(area):
    if is_in_groups(area, target_required_groups):
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

func get_direction_vector() -> Vector3:
    return get_error_vector().normalized()

func get_error_vector() -> Vector3:
    return target_point - global_transform.origin