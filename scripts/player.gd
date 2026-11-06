extends RigidBody2D

const GRAVITY = 9.81

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
