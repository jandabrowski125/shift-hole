extends RigidBody2D

const GRAVITY = 9.81
var isBlack = true

@export var switchDuration: float = 0.5:
	set(value):
		switchDuration = value
		
@export var maxColorIntensity: float = 10:
	set(value):
		maxColorIntensity = value

var currSwitchTime: float = 0
var isSwitching: bool = false
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	
		


func _on_collision_trigger_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		#Skalowanie CollisionShapes podobno nie działa (testowałem).
		#Workaround - skalować tylko image. Trochę do dupy, ale fajnie żeby dziura rosła.
		$Sprite2D.scale *= (self.mass + body.mass)/self.mass
		self.mass += body.mass
		$GravityArea2D.gravity = self.mass * GRAVITY
		print("Player mass increased by ", body.mass)
		body.queue_free()


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
