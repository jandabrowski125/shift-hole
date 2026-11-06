extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collision_trigger_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		self.scale *= (self.mass + body.mass)/self.mass
		self.mass += body.mass
		$GravityArea2D.gravity = self.mass * 9.81
		print("Player mass increased by ", body.mass)
		
		body.queue_free()
