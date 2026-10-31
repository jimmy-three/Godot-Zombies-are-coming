extends Label

var tween
func _ready() -> void:
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_position", global_position - Vector2(0, 50), 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(queue_free)

func _process(_delta: float) -> void:
	pass

func restart(pos):
	tween.kill()
	global_position = pos
	modulate.a = 1.0
	$ExistTimer.start(0.5)
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_position", global_position - Vector2(0, 50), 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(queue_free)
