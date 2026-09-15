extends CharacterBody3D

## Super Paper Mario style 2D/3D dimension-flip controller.
##
## TWO_D   -> player moves along X. Camera faces the X/Y plane, so the
##            world reads as a flat, side-scrolling "2D" game.
## THREE_D -> player moves along Z instead. The camera has rotated 90
##            degrees around Y, so it *looks* like you're still moving
##            left/right on screen, but you're now walking into depth
##            that was hidden behind foreground geometry a moment ago.
##
## Gravity/jumping (the Y axis) is completely unaffected by the mode -
## only the horizontal input axis being controlled changes.

enum Mode { TWO_D, THREE_D }

@export var speed: float = 7.1
@export var jump_velocity: float = 9.0
@export var gravity: float = 26.0
@export var flip_duration: float = 0.45
@export var shift_speed: float = 10

var mode: Mode = Mode.TWO_D
var can_flip: bool = true
var can_jump: bool = true
var spawn_position: Vector3

var _is_flipping: bool = false
var _is_dead: bool = false
var _prev_jump_key: bool = false
var _prev_flip_key: bool = false

@onready var sprite: Sprite3D = $Sprite3D
@onready var camera_rig: Node3D = get_tree().get_first_node_in_group("camera_rig")
@onready var fade_overlay: CanvasLayer = get_tree().get_first_node_in_group("fade_overlay")


func _ready() -> void:
	spawn_position = global_position

	# Give the sprite a visible placeholder if no texture has been assigned.
	# Swap this out in the editor for your own spritesheet/AnimatedSprite3D.
	if sprite.texture == null:
		sprite.texture = _make_placeholder_texture()

	if camera_rig:
		camera_rig.target = self


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	_handle_jump()
	_handle_flip_input()
	_handle_movement()

	move_and_slide()


func _handle_movement() -> void:
	var input_dir: float = _get_input_axis()

	match mode:
		Mode.TWO_D:
			velocity.x = input_dir * speed
			velocity.z = 0.0
		Mode.THREE_D:
			velocity.z = -input_dir * speed
			velocity.x = 0.0

	if input_dir != 0.0:
		sprite.flip_h = input_dir < 0.0


func _get_input_axis() -> float:
	# Plain key polling so this works with zero Input Map setup.
	var dir: float = 0.0

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		dir -= 1.0

	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		dir += 1.0

	return dir


func _handle_jump() -> void:
	var jump_key: bool = Input.is_physical_key_pressed(KEY_SPACE)

	# Jump only if jumping is allowed.
	if jump_key and not _prev_jump_key and is_on_floor() and can_jump:
		velocity.y = jump_velocity

	_prev_jump_key = jump_key


func _handle_flip_input() -> void:
	var flip_key: bool = Input.is_physical_key_pressed(KEY_F)

	if flip_key and not _prev_flip_key:
		flip_mode()

	_prev_flip_key = flip_key


func flip_mode() -> void:
	if _is_flipping or not can_flip:
		return

	_is_flipping = true
	mode = Mode.THREE_D if mode == Mode.TWO_D else Mode.TWO_D

	if camera_rig and camera_rig.has_method("flip_to"):
		camera_rig.flip_to(mode)

	await get_tree().create_timer(flip_duration).timeout
	_is_flipping = false


## Called by NoFlipZone areas to lock/unlock flipping.
func set_can_flip(value: bool) -> void:
	can_flip = value


## Called by NoJumpZone areas to lock/unlock jumping.
func set_can_jump(value: bool) -> void:
	can_jump = value


## Called by KillZone/kill blocks.
## Freezes the player, flashes the screen white,
## teleports back to spawn, then fades back in.
func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	velocity = Vector3.ZERO

	if fade_overlay and fade_overlay.has_method("flash_to_white"):
		await fade_overlay.flash_to_white()
	else:
		await get_tree().create_timer(0.2).timeout

	_respawn()

	if fade_overlay and fade_overlay.has_method("clear_to_visible"):
		await fade_overlay.clear_to_visible()

	_is_dead = false


func _respawn() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	mode = Mode.TWO_D

	if camera_rig and camera_rig.has_method("flip_to"):
		camera_rig.flip_to(0)


func _make_placeholder_texture() -> ImageTexture:
	var img: Image = Image.create(28, 44, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.95, 0.35, 0.25, 1.0))
	return ImageTexture.create_from_image(img)
