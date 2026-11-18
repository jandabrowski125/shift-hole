extends RigidBody2D

const GRAVITY = 9.81
var isBlack = true

@export var switchDuration: float = 1:
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
	if isSwitching: _shift_color(delta)
		
		


func _on_collision_trigger_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		#Skalowanie CollisionShapes podobno nie działa (testowałem).
		#Workaround - skalować tylko image. Trochę do dupy, ale fajnie żeby dziura rosła.
		$Sprite2D.scale *= (self.mass + body.mass)/self.mass
		self.mass += body.mass
		$GravityArea2D.gravity = self.mass * GRAVITY
		print("Player mass increased by ", body.mass)
		body.queue_free()

func _shift_color(delta: float):
	currSwitchTime += delta
	print(currSwitchTime)
	if currSwitchTime >= switchDuration:
		#switch zakonczony
		#upewniam sie ze jestem w kolorze ktory chce:
		var c = int(!isBlack) * maxColorIntensity
		$Sprite2D.modulate = Color(c,c,c)
		currSwitchTime = 0
		isSwitching = false
		return
	var newIntensity = $Sprite2D.modulate.r + (1 - 2*int(isBlack)) * colorSwitchStep*delta
	$Sprite2D.modulate = Color(newIntensity,newIntensity,newIntensity)

func _input(event):
	if event.is_action_pressed("shift"):
		print("Shifting started")
		if !isSwitching:
			isBlack = !isBlack
			isSwitching = true
			self.gravity_scale *= -1
			$GravityArea2D.gravity *= -1
