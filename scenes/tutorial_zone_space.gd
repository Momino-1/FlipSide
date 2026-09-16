extends Area3D

@export var png_1: Texture2D
@export var png_2: Texture2D
@export var blink_time: float = 0.5
@export var fade_time: float = 0.3

@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect

var fade_tween: Tween
var blink_timer: Timer
var player_inside: bool = false
var showing_first: bool = true


func _ready() -> void:
	texture_rect.modulate.a = 0.0

	# Create timer
	blink_timer = Timer.new()
	blink_timer.wait_time = blink_time
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	add_child(blink_timer)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Start with PNG 1
	texture_rect.texture = png_1


func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = true
	showing_first = true
	texture_rect.texture = png_1

	blink_timer.start()

	show_tutorial()


func _on_body_exited(body: Node3D) -> void:
	if body.name != "Player":
		return

	player_inside = false
	blink_timer.stop()

	hide_tutorial()


func _on_blink_timer_timeout() -> void:
	if not player_inside:
		return

	showing_first = not showing_first

	if showing_first:
		texture_rect.texture = png_1
	else:
		texture_rect.texture = png_2


func show_tutorial() -> void:
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()

	fade_tween.tween_property(
		texture_rect,
		"modulate:a",
		1.0,
		fade_time
	)


func hide_tutorial() -> void:
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()

	fade_tween.tween_property(
		texture_rect,
		"modulate:a",
		0.0,
		fade_time
	)
