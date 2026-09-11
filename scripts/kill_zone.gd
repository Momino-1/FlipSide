extends Area3D

## Attach to any Area3D with a matching CollisionShape3D - spikes, lava,
## a bottomless pit, or (as in this demo) a solid-looking "kill block".
## Anything that enters and has a die() method gets killed.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("die"):
		body.die()
