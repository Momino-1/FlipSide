extends Area3D

@export var checkpoint_number: int = 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	if body.has_method("set_checkpoint"):
		body.set_checkpoint(
			checkpoint_number,
			global_position,
			rotation
		)
