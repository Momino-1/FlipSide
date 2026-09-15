extends Node3D

## Builds a "guess the safe panel" bridge: `row_count` rows, each with
## two glass panels side by side, exactly one of which is safe per row.
## Layout is randomized every time the scene runs.

@export var row_count: int = 8
@export var tile_size: float = 2.0
@export var row_spacing: float = 2.2
@export var lane_gap: float = 0.15
@export var start_z: float = -2.0

const GlassPanelScene: PackedScene = preload("res://scenes/GlassPanel.tscn")

@onready var end_platform: CSGBox3D = $EndPlatform
@onready var chasm: Area3D = $Chasm
@onready var chasm_shape: CollisionShape3D = $Chasm/CollisionShape3D
@onready var finish_zone: Area3D = $FinishZone


func _ready() -> void:
	randomize()
	_build_bridge()
	_place_end_pieces()


func _build_bridge() -> void:
	var lane_offset: float = (tile_size + lane_gap) * 0.5

	for i in range(row_count):
		var safe_side: int = randi() % 2  # 0 = left is safe, 1 = right is safe
		var z: float = start_z - float(i) * row_spacing

		var left: GlassPanel = GlassPanelScene.instantiate() as GlassPanel
		left.is_safe = (safe_side == 0)
		left.position = Vector3(-lane_offset, 0.0, z)
		add_child(left)

		var right: GlassPanel = GlassPanelScene.instantiate() as GlassPanel
		right.is_safe = (safe_side == 1)
		right.position = Vector3(lane_offset, 0.0, z)
		add_child(right)


func _place_end_pieces() -> void:
	var last_row_z: float = start_z - float(row_count - 1) * row_spacing
	var end_z: float = last_row_z - row_spacing * 0.5 - 1.5

	end_platform.position.z = end_z
	finish_zone.position.z = end_z

	var chasm_length: float = (start_z - end_z) + 6.0
	var chasm_center_z: float = (start_z + end_z) * 0.5

	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(tile_size * 2.0 + lane_gap + 2.0, 6.0, chasm_length)
	chasm_shape.shape = box
	chasm.position.z = chasm_center_z
