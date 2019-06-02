tool
extends Spatial

# Requires BasicMovement

export var sight_radius = 300.0 setget set_sight_radius
export var target_required_groups = ["red-team", "ship"]

var target_node = null

func _ready():
    set_process(false)

func _process(delta):
    if target_node != null:
        get_parent().get_node("BasicMovement").target_position = target_node.global_transform.origin

func set_sight_radius(new_sight_radius):
    if has_node("DetectionArea"):
        $DetectionArea/CollisionShape.shape.radius = new_sight_radius
    sight_radius = new_sight_radius

func _on_DetectionArea_body_entered(body):
    for g in target_required_groups:
        if not body.is_in_group(g):
            return
    target_node = body
    set_process(true)
    get_parent().fire_at(body)