extends CanvasLayer

@export var total_shards: int = 50

@onready var shard_counter: Label = $ShardUI/ShardCounter
@onready var progress_bar: ProgressBar = $ShardUI/ProgressBar

var player: Node3D


func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("Player")

	if player == null:
		push_error("HUD: Player was not found!")
		return

	progress_bar.min_value = 0
	progress_bar.max_value = total_shards
	progress_bar.value = player.shards
	progress_bar.show_percentage = false

	update_counter()


func _process(_delta: float) -> void:
	if player:
		update_counter()


func update_counter() -> void:
	var collected: int = player.shards

	shard_counter.text = "SHARDS × " + str(collected) + " / " + str(total_shards)

	progress_bar.value = collected
