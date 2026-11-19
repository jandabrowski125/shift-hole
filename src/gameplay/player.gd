extends RigidBody2D

const GRAVITY = 9.81
var isBlack = true
var nearest_danger: Vector2
var in_danger: bool = false
var material_instance: ShaderMaterial
@export var shader: Shader

@export var switchDuration: float = 0.5:
	set(value):
		switchDuration = value
		
@export var maxColorIntensity: float = 10:
	set(value):
		maxColorIntensity = value

var currSwitchTime: float = 0
var isSwitching: bool = false
var danger_radius: float = 0
var colorSwitchStep: float = maxColorIntensity/switchDuration

@export var startVelocityX: float = 0:
	set(value):
		startVelocityX = value
@export var startVelocityY: float = 0:
	set(value):
		startVelocityY = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GravityArea2D.gravity = self.mass * GRAVITY
	self.linear_velocity = Vector2(startVelocityX, startVelocityY)
	SignalBus.connect_signal("danger_proximity", danger_proximity_handler)
	SignalBus.connect_signal("safe_distance", safe_distance_handler)
	material_instance = ShaderMaterial.new()
	material_instance.shader = shader
	$Sprite2D.material = material_instance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_danger:
		material_instance.set_shader_parameter(
			"proximity_factor",
			calculate_proximity_factor(
				global_position.distance_to(nearest_danger)
			)
		)
		material_instance.set_shader_parameter(
			"stretch_direction", 
			global_position.direction_to(nearest_danger)
		)

func _on_collision_trigger_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		#Skalowanie CollisionShapes podobno nie działa (testowałem).
		#Workaround - skalować tylko image. Trochę do dupy, ale fajnie żeby dziura rosła.
		$Sprite2D.scale *= (self.mass + body.mass)/self.mass
		self.mass += body.mass
		$GravityArea2D.gravity = self.mass * GRAVITY
		print("Player mass increased by ", body.mass)
		body.queue_free()

func danger_proximity_handler(data: Array):
	nearest_danger = data[0] as Vector2
	danger_radius = data[1] as float
	in_danger = true

@warning_ignore("unused_parameter")
func safe_distance_handler(danger_pos: Vector2):
	in_danger = false
	
func calculate_proximity_factor(
	distance: float, 
	maximum: float = 0.2
):
	return min(maximum * (1 - distance/danger_radius), maximum)

func _input(event):
	if event.is_action_pressed("shift") and not isSwitching:
		isBlack = !isBlack
		isSwitching = true
		gravity_scale *= -1
		$GravityArea2D.gravity *= -1

		var base = $Sprite2D.scale
		var c = 0.0 if isBlack else maxColorIntensity

		var t = create_tween()
		if isBlack:
			# white -> black
			t.tween_property($Sprite2D, "scale", Vector2.ZERO, switchDuration / 3)
			t.tween_property($Sprite2D, "modulate", Color(c, c, c), switchDuration / 3)
			t.tween_property($Sprite2D, "scale", base, switchDuration / 3) \
				.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		else:
			# black -> white
			t.tween_property($Sprite2D, "scale", base * Vector2(1.3, 0.7), 0.08)
			t.parallel().tween_property($Sprite2D, "modulate", Color(c, c, c), 0.08)
			t.tween_property($Sprite2D, "scale", base, 0.4) \
				.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

		t.finished.connect(func(): isSwitching = false)
