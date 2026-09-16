extends Area3D

@export var blink_time: float = 0.5
@export var fade_time: float = 0.3

@onready var left_arrow: TextureRect = $CanvasLayer/LeftArrow
@onready var right_arrow: TextureRect = $CanvasLayer/RightArrow

var blink_timer: Timer
var player_inside: bool = false
var left_visible: bool = true


func _ready() -> void:
	left_arrow.modulate.a = 0.0
	right_arrow.modulate.a = 0.0

	blink_timer = Timer.new()
	blink_timer.wait_time = blink_time
	blink_timer.timeout.connect(_on_blink)
	add_child(blink_timer)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = true
	left_visible = true

	left_arrow.modulate.a = 1.0
	right_arrow.modulate.a = 0.3

	blink_timer.start()


func _on_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = false
	blink_timer.stop()

	fade_out()


func _on_blink() -> void:
	if not player_inside:
		return

	left_visible = not left_visible

	if left_visible:
		left_arrow.modulate.a = 1.0
		right_arrow.modulate.a = 0.3
	else:
		left_arrow.modulate.a = 0.3
		right_arrow.modulate.a = 1.0


func fade_out() -> void:
	var tween := create_tween()
	tween.set_parallel()

	tween.tween_property(
		left_arrow,
		"modulate:a",
		0.0,
		fade_time
	)

	tween.tween_property(
		right_arrow,
		"modulate:a",
		0.0,
		fade_time
	)
