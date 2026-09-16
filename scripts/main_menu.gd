extends Control

@export var play_scene_path: String = "res://scenes/Main.tscn"

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(play_scene_path)


func _on_quit_pressed() -> void:
	get_tree().quit()
