extends Area3D

@export var fade_time: float = 1.0

@onready var music: AudioStreamPlayer2D = $Music

var player_inside: bool = false
var fade_tween: Tween


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	music.volume_db = -80.0
	music.stop()


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = true

	# Cancel any previous fade.
	if fade_tween:
		fade_tween.kill()

	# Start the music.
	if not music.playing:
		music.play()

	# Fade in.
	fade_tween = create_tween()
	fade_tween.tween_property(
		music,
		"volume_db",
		0.0,
		fade_time
	)


func _on_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = false

	# Cancel any previous fade.
	if fade_tween:
		fade_tween.kill()

	# Fade out.
	fade_tween = create_tween()
	fade_tween.tween_property(
		music,
		"volume_db",
		-80.0,
		fade_time
	)

	fade_tween.tween_callback(music.stop)
