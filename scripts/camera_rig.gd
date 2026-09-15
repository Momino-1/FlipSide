extends Node3D

## Camera pivot for the dimension flip.

@export var camera_height: float = 4.0
@export var camera_distance: float = 12.0
@export var follow_speed: float = 8.0
@export var flip_duration: float = 0.45

## How transparent objects become.
@export_range(0.0, 1.0) var object_transparency: float = 0.7

## How quickly objects fade in/out.
@export var fade_duration: float = 0.15

## Extra area around the player to check.
@export var detection_radius: float = 0.45

var target: Node3D
var _flip_tween: Tween

var current_objects: Array[GeometryInstance3D] = []

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	add_to_group("camera_rig")

	camera.position = Vector3(0, camera_height, camera_distance)
	camera.look_at(global_position, Vector3.UP)


func _process(delta: float) -> void:
	if target:
		var t: float = clamp(follow_speed * delta, 0.0, 1.0)
		global_position = global_position.lerp(target.global_position, t)

	check_camera_objects()


func check_camera_objects() -> void:
	if target == null:
		return

	var space_state := get_world_3d().direct_space_state

	var objects_found: Array[GeometryInstance3D] = []

	# Several points around the player.
	# This makes detection work even when the player is very close
	# to an object.
	var target_points: Array[Vector3] = [
		target.global_position,
		target.global_position + Vector3(0, 0.35, 0),
		target.global_position + Vector3(0, 0.7, 0),
		target.global_position + Vector3(0, -0.35, 0),
		target.global_position + Vector3(detection_radius, 0, 0),
		target.global_position + Vector3(-detection_radius, 0, 0),
		target.global_position + Vector3(0, 0, detection_radius),
		target.global_position + Vector3(0, 0, -detection_radius)
	]

	for point in target_points:
		var object := find_object_between(
			space_state,
			camera.global_position,
			point
		)

		if object != null and not objects_found.has(object):
			objects_found.append(object)

	# Fade objects that are no longer blocking the camera.
	for old_object in current_objects:
		if not objects_found.has(old_object):
			fade_object(old_object, 0.0)

	# Fade newly detected objects.
	for new_object in objects_found:
		if not current_objects.has(new_object):
			fade_object(new_object, object_transparency)

	current_objects = objects_found


func find_object_between(
	space_state: PhysicsDirectSpaceState3D,
	from: Vector3,
	to: Vector3
) -> GeometryInstance3D:

	var exclude_list: Array[RID] = []

	if target is CollisionObject3D:
		exclude_list.append(target.get_rid())

	while true:
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = exclude_list
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var result := space_state.intersect_ray(query)

		if result.is_empty():
			return null

		var hit_object: Node3D = result.collider

		# IMPORTANT:
		# Anything in the "solid" group is ignored.
		# It will NEVER become transparent.
		if hit_object.is_in_group("solid"):
			if hit_object is CollisionObject3D:
				exclude_list.append(hit_object.get_rid())
				continue
			else:
				return null

		# Find the visual GeometryInstance3D.
		var geometry := find_geometry(hit_object)

		if geometry != null:
			# Don't fade solid geometry even if its parent is solid.
			if geometry.is_in_group("solid"):
				if hit_object is CollisionObject3D:
					exclude_list.append(hit_object.get_rid())
					continue
				return null

			return geometry

		# Ignore objects without geometry.
		if hit_object is CollisionObject3D:
			exclude_list.append(hit_object.get_rid())
		else:
			return null

	return null


func find_geometry(object: Node3D) -> GeometryInstance3D:
	# Check the object itself.
	if object is GeometryInstance3D:
		return object

	# Check parents.
	var current: Node = object.get_parent()

	while current != null:
		if current is GeometryInstance3D:
			return current

		current = current.get_parent()

	# Check children.
	for child in object.get_children():
		if child is GeometryInstance3D:
			return child

	return null


func fade_object(
	object: GeometryInstance3D,
	target_transparency: float
) -> void:

	if not is_instance_valid(object):
		return

	# Never fade objects belonging to the solid group.
	if object.is_in_group("solid"):
		return

	var tween := create_tween()

	tween.tween_property(
		object,
		"transparency",
		target_transparency,
		fade_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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
