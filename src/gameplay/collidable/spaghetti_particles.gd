extends CPUParticles2D

var closest_danger: Vector2
var in_danger: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect_signal("danger_proximity", handle_danger_proximity)
	SignalBus.connect_signal("safe_distance", handle_safe_distance)
	gravity = Vector2.ZERO
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !in_danger:
		#optimize to maybe sleep this node?
		return
	#direction = global_position.direction_to(closest_danger)
	#linear_accel_max = closest_danger.distance_to(global_position) * 10
	#linear_accel_min = linear_accel_max / 10
	var distance_to_danger := closest_danger.distance_to(global_position)
	speed_scale = pow((1 - distance_to_danger/160),2)
	gravity = (closest_danger - global_position)*1000
	lifetime = sqrt(2 * closest_danger.distance_to(global_position) / gravity.length())
func handle_danger_proximity(data: Array):
	closest_danger = data[0] as Vector2
	in_danger = true
	emitting = true

func handle_safe_distance(danger_from: Vector2):
	in_danger = false
	emitting = false
