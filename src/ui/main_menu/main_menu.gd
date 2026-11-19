extends Control

@export var initial_scene: StringName = &""
@onready var new_game_button: Button = $VBoxContainer/StartGame
@onready var exit_button: Button = $VBoxContainer/Exit

func _ready() -> void:
	pass


func _on_new_game_pressed() -> void:
	SceneManager.load_first_level()


func _on_exit_pressed() -> void:
	get_tree().quit()
