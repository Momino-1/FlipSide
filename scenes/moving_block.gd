extends AnimatableBody3D

@export var move_direction: Vector3 = Vector3(5, 0, 0)
@export var move_time: float = 2.0
@export var wait_at_end: float = 0.5

var start_position: Vector3
var moving: bool = false
var current_tween: Tween

@onready var sensor: Area3D = $Sensor


func _ready() -> void:
	start_position = global_position
	
	sensor.body_entered.connect(_on_sensor_body_entered)


func _on_sensor_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	
	# Don't activate it again while it's already doing its trip
	if moving:
		return
	
	moving = true
	start_platform()


func start_platform() -> void:
	var end_position := start_position + move_direction
	
	current_tween = create_tween()
	
	# Go to the other side
	current_tween.tween_property(
		self,
		"global_position",
		end_position,
		move_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	# Wait at the end
	current_tween.tween_interval(wait_at_end)
	
	# Come back
	current_tween.tween_property(
		self,
		"global_position",
		start_position,
		move_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	await current_tween.finished
	
	moving = false
