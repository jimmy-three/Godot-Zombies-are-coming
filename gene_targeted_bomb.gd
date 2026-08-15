extends Area2D

var exploded = false
var window_size
var explosion_alpha = 0.7
var targeted_y = 0

func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size

func _process(delta: float) -> void:
	if position.y < targeted_y:
		position.y += 500 * delta
	elif not exploded:
		explode()
		exploded = true
	if exploded:
		queue_redraw()
		var areas = get_overlapping_areas()
		for area in areas:
			if area.is_in_group("enemies") and area.has_method("take_damage") and area.visible:
				area.take_damage(5000 * delta * explosion_alpha, 0)

func explode():
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = false
	var tween = create_tween()
	tween.tween_property(self, "explosion_alpha", 0.0, 10)
	await tween.finished
	queue_free()

func _draw() -> void:
	if exploded:
		draw_circle(to_local(global_position), 480, Color(0.0, 0.66, 0.0, explosion_alpha))
