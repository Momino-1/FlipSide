extends Area3D

## How many shards this collectible gives.
@export var value: int = 1

## Shard animation.
@export var rotation_speed: float = 2.5
@export var float_height: float = 0.25
@export var float_speed: float = 2.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

var start_y: float
var time_passed: float = 0.0
var collected: bool = false


func _ready() -> void:
	# Connect pickup detection.
	body_entered.connect(_on_body_entered)

	# Remember starting height.
	start_y = position.y

	# Make sure the sound isn't playing at the start.
	if pickup_sound:
		pickup_sound.stop()


func _process(delta: float) -> void:
	if collected:
		return

	time_passed += delta

	# Slowly rotate the shard.
	if mesh:
		mesh.rotate_y(rotation_speed * delta)

	# Gently float up and down.
	position.y = start_y + sin(time_passed * float_speed) * float_height


func _on_body_entered(body: Node3D) -> void:
	# Don't collect twice.
	if collected:
		return

	# Only the Player can collect it.
	if body.name != "Player":
		return

	collected = true

	# Give the player the shard.
	if body.has_method("add_shard"):
		body.add_shard(value)

	# Disable collision immediately.
	if collision:
		collision.set_deferred("disabled", true)

	# Hide the shard.
	if mesh:
		mesh.visible = false

	# Play pickup sound.
	if pickup_sound:
		pickup_sound.play()

	# Wait for the pickup sound before deleting the shard.
	if pickup_sound and pickup_sound.stream:
		await pickup_sound.finished
	else:
		await get_tree().create_timer(0.2).timeout

	queue_free()
