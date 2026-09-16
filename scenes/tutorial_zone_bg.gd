extends Area3D

@export var fade_time: float = 0.3

var panel: Panel


func _ready() -> void:
	panel = get_node_or_null("BlurUI/Panel")

	if panel == null:
		print("ERROR: Could not find BlurUI/Panel!")
		print("Children of TutorialZone:")
		for child in get_children():
			print(" - ", child.name)
		return

	panel.modulate.a = 0.0

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	if panel == null:
		return

	var tween := create_tween()
	tween.tween_property(
		panel,
		"modulate:a",
		1.0,
		fade_time
	)


func _on_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return

	if panel == null:
		return

	var tween := create_tween()
	tween.tween_property(
		panel,
		"modulate:a",
		0.0,
		fade_time
	)
