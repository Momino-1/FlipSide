extends CanvasLayer

## Reusable fullscreen flash, e.g. for death/respawn transitions.
## Call `await fade_overlay.flash_to_white()` then reposition the player,
## then `await fade_overlay.clear_to_visible()`.

@onready var rect: ColorRect = $ColorRect


func _ready() -> void:
	add_to_group("fade_overlay")
	rect.color = Color(1.0, 1.0, 1.0, 0.0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func flash_to_white(duration: float = 0.2) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(rect, "color:a", 1.0, duration)
	await tw.finished


func clear_to_visible(duration: float = 0.3) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(rect, "color:a", 0.0, duration)
	await tw.finished
