extends Area2D

var randomizer = RandomNumberGenerator.new()
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var speed = 500
var scatter_time_out = false
func _ready() -> void:
	set_process(false)
	reset()

func reset():
	scatter_time_out = false
	$ScatterTimer.start(0.4)
	randomizer.randomize()
	velocity = Vector2(randomizer.randf_range(-2.0, 2.0), randomizer.randf_range(-2.0, 2.0))

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not scatter_time_out:
		position += velocity * delta * speed
		velocity /= 1.2
	else:
		direction = (player.global_position - position).normalized()
		position += direction * delta * speed

func _on_scatter_timer_timeout() -> void:
	scatter_time_out = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		scatter_time_out = false
		Global.coin += 2
		CoinPool.return_coin(self)
