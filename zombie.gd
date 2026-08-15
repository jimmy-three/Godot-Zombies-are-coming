extends Area2D

var randomizer = RandomNumberGenerator.new()
var speed = 100
var life = 100
var type = 1
var type_dictionary = {1 : ["normal", 100, 100, 10, 10, 1], 2 : ["normal boss", 50, 1800, 30, 200, 2], 3 : ["scout", 150, 75, 10, 7, 1], 
4 : ["scout boss", 100, 1000, 30, 180, 2], 5 : ["soldier", 60, 180, 10, 12, 1], 6 : ["soldier boss", 30, 3000, 30, 260, 2]}  #[名字，速度, 血量, 碰撞箱半径, 获得金币（±20%），伤害],奇数为普通，偶数为boss
var direction = Vector2.RIGHT
var is_moving = true
var self_repel = 0

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
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	self_repel = min(self_repel, 200)
	if is_moving:
		direction = (player.global_position - global_position).normalized()
#############################以下由AI编写
		var move_vec = direction * (speed - self_repel) * delta
		# 障碍检测
		var space = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position + move_vec + direction * type_dictionary[type][3])
		query.collide_with_bodies = true
		query.collide_with_areas = false
		query.exclude = [self, player]
		
		var result = space.intersect_ray(query)
		if result.is_empty():
			position += move_vec
		else:
			var normal = result["normal"]
			var slide = move_vec - normal * move_vec.dot(normal)
			position += slide
#############################以上由AI编写
		look_at(player.global_position)
	else:
		position -= direction * self_repel * delta if speed - self_repel < 0 else Vector2.ZERO
		player.take_damage(type_dictionary[type][5])
	self_repel -= 5 * (3 if type % 2 == 0 else 1) if self_repel > 0 else 0

func take_damage(damage, repel):
	print("僵尸受伤，伤害：" + str(damage))
	life -= damage
	self_repel += repel
	if life <= 0 and visible:
		die()

func die():
	#获得金币
	for i in range((type_dictionary[type][4]) * (randomizer.randf_range(0.8, 1.2))/2):
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
