extends Area2D

var randomizer = RandomNumberGenerator.new()
var speed = 100
var life = 100
var type = 1
#[名字，速度, 血量, 碰撞箱半径, 获得金币（±20%），伤害],奇数为普通，偶数为boss
var type_dictionary = {1 : ["normal", 100, 100, 10, 10, 1], 
2 : ["normal boss", 50, 1800, 30, 200, 2], 
3 : ["scout", 150, 75, 10, 7, 1], 
4 : ["scout boss", 100, 1000, 30, 180, 2], 
5 : ["soldier", 60, 160, 10, 12, 1], 
6 : ["soldier boss", 30, 3000, 30, 260, 2],
7 : ["robot", 110, 110, 10, 20, 1],
8 : ["robot boss", 50, 2100, 30, 315, 2]}  
var direction = Vector2.RIGHT
var is_moving = true
var self_repel = 0
var player
var damage_text
var damage_text_scene = preload("res://damage_text.tscn")

func _ready() -> void:
	reset()

func reset():
	var Collision = CircleShape2D.new()
	Collision.radius = type_dictionary[type][3]
	$CollisionShape2D.shape = Collision
	$AnimatedSprite2D.play(type_dictionary[type][0])
	randomizer.randomize()
	speed = type_dictionary[type][1] * (pow(2, Global.difficulty / 100.0))
	life = type_dictionary[type][2] * (pow(2, Global.difficulty / 50.0))

func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	self_repel = min(self_repel, 220)
	#移动
	if visible:
		if is_moving:
			if type != 7 and type != 8:
				direction = (player.global_position - global_position).normalized()
			else:
				smart_move()
			position += direction * (speed - self_repel) * delta
			look_at(player.global_position)
			direction = Vector2.RIGHT.rotated(rotation)
		else:
			position -= direction * self_repel * delta if speed - self_repel < 0 else Vector2.ZERO
			player.take_damage(type_dictionary[type][5])
	#击退值减少
	self_repel -= 5 * (3 if type % 2 == 0 else 1) if self_repel > 0 else 0

func take_damage(damage, repel):
	print("僵尸受伤，伤害：" + str(damage))
	
	if Global.damage_display:
		if (not is_instance_valid(damage_text) or damage_text.is_queued_for_deletion()) or damage_text.get_node("ExistTimer").time_left <= 0.25:
			damage_text = damage_text_scene.instantiate()
			damage_text.text = str(int(damage))
			damage_text.global_position = global_position - Vector2(15, 30)
			get_parent().add_child(damage_text)
		else:
			damage_text.restart(global_position - Vector2(15, 30))
			damage_text.text = str(int(damage) + int(damage_text.text))
	
	modulate = Color(1.5, 1.5, 1.5, 1.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	
	life -= damage
	self_repel += repel
	if life <= 0 and visible:
		die()

func die():
	var coins = int((type_dictionary[type][4]) * (randomizer.randf_range(0.8, 1.2))/2)
	#获得金币
	for i in range(coins):
		var coin = CoinPool.get_coin()
		coin.position = position
	#死亡
	print("僵尸死亡: type=", type, "，life=", life, ", visible=", visible)
	ZombiePool.return_zombie(self)
	Global.Zombie_list.erase(self)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_moving = false

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_moving = true

func smart_move(): #左右躲子弹
	var bullets = get_tree().get_nodes_in_group("bullets")
	var distance
	var min_distance = INF
	var nearest_bullet
	for bullet in bullets:
		distance = global_position.distance_squared_to(bullet.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_bullet = bullet
	if not bullets.is_empty() and min_distance <= 40000:
		var bullet_direction = (nearest_bullet.global_position - global_position).normalized()
		if bullet_direction.angle_to(direction) < 0:
			direction = (player.global_position - global_position).normalized().rotated(-PI/2) * 0.8
		else:
			direction = (player.global_position - global_position).normalized().rotated(PI/2) * 0.8
	else:
		direction = (player.global_position - global_position).normalized()
