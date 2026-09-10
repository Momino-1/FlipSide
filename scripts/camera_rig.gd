extends Node3D

## Camera pivot for the dimension flip.
##
## The Camera3D child sits offset behind the rig's local origin. Because
## it's a *child*, rotating this rig around Y makes the camera orbit
## around whatever it's centered on (the player) while always facing it -
## exactly like the stage rotating in Super Paper Mario.

@export var camera_height: float = 4.0
@export var camera_distance: float = 12.0
@export var follow_speed: float = 8.0
@export var flip_duration: float = 0.45

var target: Node3D
var _flip_tween: Tween

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	add_to_group("camera_rig")
	camera.position = Vector3(0, camera_height, camera_distance)
	camera.look_at(global_position, Vector3.UP)


func _process(delta: float) -> void:
	if target:
		var t: float = clamp(follow_speed * delta, 0.0, 1.0)
		global_position = global_position.lerp(target.global_position, t)


## mode: 0 = TWO_D (facing forward), 1 = THREE_D (rotated 90 deg)
## Matches Player.Mode - passed as a plain int so this script has no
## hard dependency on the player script.
func flip_to(mode: int) -> void:
	var target_y: float = deg_to_rad(90.0) if mode == 1 else 0.0
	if _flip_tween:
		_flip_tween.kill()
	_flip_tween = create_tween()
	_flip_tween.tween_property(self, "rotation:y", target_y, flip_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
