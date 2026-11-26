extends StaticBody2D

var radius: float = 0
var isStretched: bool = false
var material_instance: ShaderMaterial
@export var shader: Shader
var body_in_proximity: Node2D

func _ready():
	radius = (($CollisionTrigger.get_node("CollisionShape2D") as CollisionShape2D).shape as CircleShape2D).radius * scale.x
	material_instance = ShaderMaterial.new()
	material_instance.shader = shader
	$Sprite2D.material = material_instance
	
func _process(delta: float):
	if isStretched:
		if body_in_proximity == null:
			return
		material_instance.set_shader_parameter(
			"proximity_factor",
			calculate_proximity_factor(
				global_position.distance_to(body_in_proximity.global_position)
			)
		)
		material_instance.set_shader_parameter(
			"stretch_direction", 
			global_position.direction_to(body_in_proximity.global_position)
		)

func _on_collision_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		SignalBus.emit("danger_proximity", [global_position, radius])
		isStretched = true
		body_in_proximity = body

func _on_collision_trigger_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		isStretched = false
		SignalBus.emit("safe_distance", global_position)
		body_in_proximity = null

func calculate_proximity_factor(
	distance: float, 
	maximum: float = 0.2
):
	return min(maximum * (1 - distance/radius), maximum)


func _on_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.emit("entered_gravity_layer")

func _on_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		SignalBus.emit("left_gravity_layer")
	pass # Replace with function body.
