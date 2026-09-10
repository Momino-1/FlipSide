extends Node3D

## Camera pivot for the dimension flip.

@export var camera_height: float = 4.0
@export var camera_distance: float = 12.0
@export var follow_speed: float = 8.0
@export var flip_duration: float = 0.45

## How transparent solid walls become
@export_range(0.0, 1.0) var wall_transparency: float = 0.7

var target: Node3D
var _flip_tween: Tween

var current_wall: GeometryInstance3D = null

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	add_to_group("camera_rig")

	camera.position = Vector3(0, camera_height, camera_distance)
	camera.look_at(global_position, Vector3.UP)


func _process(delta: float) -> void:
	if target:
		var t: float = clamp(follow_speed * delta, 0.0, 1.0)
		global_position = global_position.lerp(target.global_position, t)

	check_camera_wall()


func check_camera_wall() -> void:
	if target == null:
		return

	var space_state = get_world_3d().direct_space_state

	var from = camera.global_position
	var to = target.global_position

	var exclude_list: Array[RID] = []

	# Don't hit the player
	exclude_list.append(target.get_rid())

	var new_wall: GeometryInstance3D = null

	while true:
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = exclude_list

		var result = space_state.intersect_ray(query)

		# Nothing is blocking the camera
		if result.is_empty():
			break

		var hit_object = result.collider

		# Only walls/objects in the "solid" group can become transparent
		if not hit_object.is_in_group("solid"):
			if hit_object is GeometryInstance3D:
				new_wall = hit_object
			break

		# Ignore objects that aren't solid and continue the ray
		if hit_object is CollisionObject3D:
			exclude_list.append(hit_object.get_rid())
		else:
			break

	# Restore the old wall
	if current_wall != null and current_wall != new_wall:
		current_wall.transparency = 0.0

	# Make the new wall transparent
	if new_wall != null:
		new_wall.transparency = wall_transparency

	current_wall = new_wall


## mode: 0 = TWO_D
## mode: 1 = THREE_D
func flip_to(mode: int) -> void:
	var target_y: float = deg_to_rad(90.0) if mode == 1 else 0.0

	if _flip_tween:
		_flip_tween.kill()

	_flip_tween = create_tween()

	_flip_tween.tween_property(
		self,
		"rotation:y",
		target_y,
		flip_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
