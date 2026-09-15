extends Node3D
class_name longglass

@export var is_safe: bool = true
@export var shatter_time: float = 0.35

var _resolved: bool = false

@onready var mesh: MeshInstance3D = $Mesh
@onready var body_shape: CollisionShape3D = $Body/CollisionShape3D
@onready var sensor: Area3D = $Sensor


func _ready() -> void:
	sensor.monitoring = true
	sensor.body_entered.connect(_on_sensor_entered)


func _on_sensor_entered(other_body: Node3D) -> void:
	if _resolved:
		return

	# Only the player should activate the glass.
	if not other_body.has_method("die"):
		return

	_resolved = true

	if is_safe:
		_play_safe_feedback()
	else:
		_shatter()


func _play_safe_feedback() -> void:
	var original_y := position.y

	var tw := create_tween()
	tw.tween_property(self, "position:y", original_y - 0.04, 0.08)
	tw.tween_property(self, "position:y", original_y, 0.12)


func _shatter() -> void:
	# Remove the physical collision immediately.
	body_shape.set_deferred("disabled", true)

	var tw := create_tween()

	tw.tween_property(
		mesh,
		"scale",
		Vector3(0.9, 0.05, 0.9),
		shatter_time
	)

	tw.parallel().tween_property(
		mesh,
		"position:y",
		mesh.position.y - 0.4,
		shatter_time
	)

	await tw.finished

	mesh.visible = false
