extends Area3D

## Reveals a floating "You crossed!" label when the player reaches it.

@onready var label: Label3D = $Label3D


func _ready() -> void:
	label.visible = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("die"):
		label.visible = true
