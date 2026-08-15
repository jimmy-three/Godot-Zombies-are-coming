extends StaticBody2D

var randomizer = RandomNumberGenerator.new()
var turn_speed = 40
var can_shoot = true
var damage = 500

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var target = get_nearest_zombie()
	if target:
		turning(target, delta)
		if abs(angle_difference((target.global_position - global_position).angle(), rotation)) < 0.01:
			shoot()

func get_nearest_zombie():
	var nearest_enemy = null
	var min_distance = INF
	for enemy in Global.Zombie_list:
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_enemy = enemy
	return nearest_enemy

func turning(enemy, delta):
	var target_angle = (enemy.global_position - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

func shoot():
	if can_shoot and Global.shell > 0:
		randomizer.randomize()
		var bullet = BulletPool.get_bullet(damage)
		bullet.direction = Vector2.RIGHT.rotated(rotation)
		bullet.rotation = rotation
		bullet.global_position = global_position
		bullet.speed = 1000
		bullet.repel = 200
		bullet.bullet_type = "shell"
		bullet.reset()
		Global.Bullet_list.append(bullet)
		can_shoot = false
		Global.shell -= 1
		$ShootTimer.start()

func _on_shoot_timer_timeout() -> void:
	can_shoot = true
