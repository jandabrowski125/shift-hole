extends Camera2D

@export_range(0.8, 3) var camera_zoom: float = 1.3
@export_range(0.0, 1.0) var smoothing: float = 0.05
@export var player: Node2D
@export var camera_boundary: Area2D
@export var trauma_decay: float = 0.8
@export var max_offset: float = 12
var trauma: float = 0
var boundary_rect: Rect2
var player_adjusted: Vector2
var nearest_danger: Vector2 = Vector2(-INF, -INF)
var in_danger: bool = false
var distance_to_danger: float = INF
var radius: float = 0
var player_radius: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = self.get_viewport_rect().get_center()
	zoom = Vector2.ONE * camera_zoom
	boundary_rect = camera_boundary.get_node("CollisionShape2D").shape.get_rect()
	player_radius = (((
		player
		.get_node("CollisionTrigger") as Area2D)
		.get_node("CollisionShape2D") as CollisionShape2D)
		.shape as CircleShape2D).radius * player.scale.x
	SignalBus.connect_signal("danger_proximity", danger_proximity_handler)
	SignalBus.connect_signal("safe_distance", safe_distance_handler)

func _process(delta: float) -> void:
	print("Zoom: ", zoom.x, " trauma: ", trauma)
	if in_danger:
		distance_to_danger = nearest_danger.distance_to(player.global_position) - player_radius
		zoom = Vector2.ONE * (camera_zoom + (1 - distance_to_danger/radius) * 0.4)
		trauma = minf((1 - distance_to_danger/radius) * 1.4, 1)
	if trauma <= 0.0:
		offset = Vector2.ZERO
		trauma = 0
		return
	trauma = maxf(trauma - trauma_decay * delta, 0.0)
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * max_offset * trauma * trauma #intencjonalny kwadrat
		

func _physics_process(delta: float) -> void:
	player_adjusted = player.global_position.clamp(
		boundary_rect.position + camera_boundary.global_position,
		boundary_rect.position + camera_boundary.global_position + boundary_rect.size
		)
	global_position = global_position.lerp(
		player_adjusted, 
		1.0 - pow(smoothing, delta)
		)

func danger_proximity_handler(data: Array):
	nearest_danger = data[0] as Vector2
	radius = data[1] as float
	in_danger = true

func safe_distance_handler(danger_pos: Vector2):
	in_danger = false
	zoom = Vector2.ONE * camera_zoom  
