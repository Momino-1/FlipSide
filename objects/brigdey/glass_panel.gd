extends Node3D
class_name GlassPanel

@export var is_safe: bool = true
@export var max_time: float = 3.0
@export var fall_distance: float = 4.0
@export var fall_time: float = 0.6

var _player_on_panel: bool = false
var _time_left: float = 0.0
var _resolved: bool = false

var _material: StandardMaterial3D
var _original_color: Color

@onready var mesh: MeshInstance3D = $Mesh
@onready var body_shape: CollisionShape3D = $Body/CollisionShape3D
@onready var sensor: Area3D = $Sensor


func _ready() -> void:
	sensor.monitoring = true

	sensor.body_entered.connect(_on_sensor_entered)
	sensor.body_exited.connect(_on_sensor_exited)

	# Make a unique material for this glass panel.
	# This prevents changing one panel from changing every panel.
	if mesh.get_surface_override_material(0) != null:
		_material = mesh.get_surface_override_material(0).duplicate()
	elif mesh.mesh != null and mesh.mesh.get_surface_count() > 0:
		var original_material = mesh.mesh.surface_get_material(0)

		if original_material is StandardMaterial3D:
			_material = original_material.duplicate()
		else:
			_material = StandardMaterial3D.new()
	else:
		_material = StandardMaterial3D.new()

	mesh.set_surface_override_material(0, _material)

	_original_color = _material.albedo_color

	_time_left = max_time


func _process(delta: float) -> void:
	if is_safe:
		return

	if _resolved:
		return

	if _player_on_panel:
		_time_left -= delta

		# 0 = completely safe
		# 1 = about to fall
		var progress: float = 1.0 - (_time_left / max_time)
		progress = clamp(progress, 0.0, 1.0)

		_update_color(progress)

		if _time_left <= 0.0:
			_fall()


func _on_sensor_entered(other_body: Node3D) -> void:
	if _resolved:
		return

	# Only react to the player.
	if not other_body.has_method("die"):
		return

	if is_safe:
		_play_safe_feedback()
		return

	_player_on_panel = true


func _on_sensor_exited(other_body: Node3D) -> void:
	if not other_body.has_method("die"):
		return

	if _resolved:
		return

	if is_safe:
		return

	_player_on_panel = false

	# Reset the timer when the player leaves.
	_time_left = max_time

	# Return the glass to its normal color.
	_update_color(0.0)


func _update_color(progress: float) -> void:
	# Start with the normal glass color.
	# Gradually mix it toward red.
	var red_color := Color(1.0, 0.05, 0.05, _original_color.a)

	_material.albedo_color = _original_color.lerp(red_color, progress)


func _play_safe_feedback() -> void:
	var original_y := position.y

	var tw := create_tween()
	tw.tween_property(self, "position:y", original_y - 0.04, 0.08)
	tw.tween_property(self, "position:y", original_y, 0.12)


func _fall() -> void:
	_resolved = true
	_player_on_panel = false

	# Disable collision immediately so the player falls through.
	body_shape.set_deferred("disabled", true)

	# Make the glass fall downward.
	var target_y := position.y - fall_distance

	var tw := create_tween()

	tw.tween_property(
		self,
		"position:y",
		target_y,
		fall_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await tw.finished

	# Hide the panel after it falls.
	visible = false
