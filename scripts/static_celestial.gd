extends StaticBody2D

var radius: float = 0

func _ready():
	radius = (($CollisionTrigger.get_node("CollisionShape2D") as CollisionShape2D).shape as CircleShape2D).radius * scale.x

func _on_collision_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		SignalBus.emit("danger_proximity", [global_position, radius])
		print(radius)
	#body.queue_free()

func _on_collision_trigger_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		SignalBus.emit("safe_distance", global_position)
