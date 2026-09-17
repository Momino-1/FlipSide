extends Area3D

@export var checkpoint_number: int = 1

@onready var spawn_point: Marker3D = $SpawnPoint
@onready var checkpoint_sound: AudioStreamPlayer3D = $CheckpointSound


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	if body.has_method("set_checkpoint"):
		body.set_checkpoint(
			checkpoint_number,
			spawn_point.global_position,
			spawn_point.global_rotation
		)

		# Play checkpoint sound
		if checkpoint_sound:
			checkpoint_sound.play()
