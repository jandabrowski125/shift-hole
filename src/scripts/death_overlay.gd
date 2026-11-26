extends ColorRect

var is_player_dead: bool = false
var switch_duration: float = 2
var player_died_text: TextureRect
var death_text_shader: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.color.a = 0.0
	SignalBus.connect_signal("player_died", player_died_handler)

func _process(delta: float) -> void:
	if is_player_dead && self.color.a < 1.0:
		self.color.a += delta
		
func player_died_handler(data: Variant = null):
	is_player_dead = true
	#jesli otrzyma true, to oznacza ze nas wsyslo, else ze wylecielismy
	player_died_text = $YouGotSucked if (data as bool) else $YouWentTooFar
	player_died_text.visible = true
	death_text_shader = player_died_text.material
	var t = create_tween()
	t.tween_property(self, "self_modulate", Color(0,0,0,1), switch_duration / 3) 
	t.tween_method(set_delta_of_shader, 0.0, 1.0, switch_duration)

func set_delta_of_shader(delta: float):
	death_text_shader.set_shader_parameter("percentage", delta)
	
