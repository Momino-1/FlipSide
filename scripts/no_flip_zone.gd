extends Area3D

## Attach to an Area3D with a CollisionShape3D covering the region where
## flipping should be disabled - mirrors the "dark rooms" in Super Paper
## Mario where Mario can't flip to 3D.

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("set_can_flip"):
		body.set_can_flip(false)


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("set_can_flip"):
		body.set_can_flip(true)
