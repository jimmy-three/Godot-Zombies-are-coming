extends PopupPanel

var timer = 0.0

func _ready() -> void:
	popup_centered()
	visible = true
	show()
	$ShowTimer.start(3)

func _process(_delta: float) -> void:
	position.y -= 5

func _on_show_timer_timeout() -> void:
	queue_free()
