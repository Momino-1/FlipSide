extends Area3D

@export var fade_time: float = 0.3

@onready var label: Label = $CanvasLayer/Label

var player_inside: bool = false


func _ready() -> void:
	label.modulate.a = 0.0

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = true

	var tween := create_tween()
	tween.tween_property(
		label,
		"modulate:a",
		1.0,
		fade_time
	)


func _on_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = false

	var tween := create_tween()
	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		fade_time
	)
