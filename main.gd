extends Node2D

@onready var grass_field = $GrassField
var turrut_scene = preload("res://turrut.tscn") 
var gene_targeted_bomb_scene = preload("res://gene_targeted_bomb.tscn") 
var player
var randomizer = RandomNumberGenerator.new()

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(randomizer.randf_range(0.275, 0.314), randomizer.randf_range(0.275, 0.314), randomizer.randf_range(0.275, 0.314), 1.0))
	Global.main = self
	player = get_tree().get_first_node_in_group("player")
	fill_grass()
	$ZombieSpawnTimer.start(Global.zombie_spawn_interval)
	$DifficultyUpTimer.start(5)
	Global.SpawnPath = $player/SpawnPath
	Global.pathFollow2D = $player/SpawnPath/PathFollow2D

func _process(_delta : float) -> void:
	use_props()
	auto_bullet_buying()
	$UI/Difficulty.text = tr("DIFFICULTY") + str(Global.difficulty)
	$UI/Life.text = tr("LIFE") + str(player.life)
	$UI/Coin.text = tr("COIN") + str(Global.coin)
	$UI/FPS.text = "FPS:" + str(Engine.get_frames_per_second())
	$UI/LeftBullet.text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[player.needed_bullet],"num" : Global.get(player.needed_bullet)})
	#检测死亡
	if player.life <= 0:
		Global.dead = true
		$UI/DeathTip.visible = true
		$UI/DeathTip/CenterContainer/Difficulty.text = tr("TODIFFICULTY") % Global.difficulty
		var tree = get_tree()
		tree.paused = true
	

func fill_grass():
	var grass_filler = grass_field.multimesh
	var spread = 6500
	var count = grass_filler.instance_count
	for i in range(count):
		var angle = randf_range(0, TAU)
		var distance = sqrt(randf_range(0, 1)) * spread / 2
		var pos = Vector2(cos(angle), sin(angle)) * distance
		var grass = Transform2D(0, Vector2(1, 1), 0, pos)
		grass_filler.set_instance_transform_2d(i, grass)

func _on_zombie_spawn_timer_timeout() -> void: #僵尸生成
	Global.pathFollow2D.progress_ratio = randf_range(0, 1)
	var spawn_pos = Global.pathFollow2D.global_position
	var zombie = ZombiePool.get_zombie()
	if zombie:
		zombie.global_position = spawn_pos
		if not Global.BossSpawn:
			zombie.type = 2 * (randi() % 3 + 1) - 1
		else:
			zombie.type = 2 * (randi() % 3 + 1)
			Global.BossSpawn = false
		Global.Zombie_list.append(zombie)
		zombie.reset()
		if Global.Zombie_list.size() > 0:
			print("僵尸生成: type=", zombie.type, " radius=", zombie.get_node("CollisionShape2D").shape.radius, " life=", zombie.life)
		Global.zombie_spawn_interval = 3.5 - 0.035 * Global.difficulty if Global.difficulty < 100 else 0.1
		$ZombieSpawnTimer.start(Global.zombie_spawn_interval)

func _on_difficulty_up_timer_timeout() -> void:
	if (Global.difficulty + 1) % 20 == 0:
		Global.BossSpawn = true
	Global.difficulty += 1

func use_props():
	if Input.is_action_just_pressed("use_props") and not Global.using_props:
		match Global.prop_type:
			"bandage":
				if Global.bandage <= 0:
						Global.show_tip(tr("NOTENOUGHBANDAGE"))
						return
				elif player.life >= Global.max_life:
						Global.show_tip(tr("FULLHPNOUSE"))
						return
				Global.using_props = true
				$UI/PropsProgressBar.value = 0
				$UI/PropsProgressBar.visible = true
				Global.show_tip(tr("USINGBANDAGE"))
				var tween_progress = create_tween()
				var tween_life = create_tween()
				if player.life + 30 <= Global.max_life:
					tween_progress.tween_property($UI/PropsProgressBar, "value", 100, 0.75)
					tween_life.tween_property($player, "life", player.life + 30, 0.75)
				else:
					tween_progress.tween_property($UI/PropsProgressBar, "value", 100, 0.75 * (Global.max_life - player.life) / 30)
					tween_life.tween_property($player, "life", Global.max_life, 0.75 * (Global.max_life - player.life) / 30)
				await tween_progress.finished
				$UI/PropsProgressBar.visible = false
				Global.bandage -= 1
				Global.using_props = false
			"energy_drinks":
				if Global.energy_drinks <= 0:
						Global.show_tip(tr("NOTENOUGHDRINKS"))
						return
				Global.using_props = true
				$UI/PropsProgressBar.value = 0
				$UI/PropsProgressBar.visible = true
				Global.show_tip(tr("USINGENERGYDRINKS"))
				var tween_progress = create_tween()
				tween_progress.tween_property($UI/PropsProgressBar, "value", 100, 0.75)
				await tween_progress.finished
				$SpeedUpTimer.start(30)
				$UI/PropsProgressBar.visible = false
				Global.energy_drinks -= 1
				Global.using_props = false
			"turrut":
				if Global.turrut <= 0:
						Global.show_tip(tr("NOTENOUGHTURRUTS"))
						return
				var turrut = turrut_scene.instantiate()
				turrut.global_position = player.global_position + Vector2.RIGHT.rotated(player.rotation) * 30
				add_child(turrut)
				Global.turrut -= 1
				Global.show_tip(tr("TURRUTPLACED"))
			"gene_targeted_bomb":
				if Global.gene_targeted_bomb <= 0:
					Global.show_tip(tr("NOTENOUGHGENETARGETEDBOMB"))
					return
				var gene_targeted_bomb = gene_targeted_bomb_scene.instantiate()
				gene_targeted_bomb.position.x = player.global_position.x
				gene_targeted_bomb.position.y = player.global_position.y - 1000
				gene_targeted_bomb.targeted_y = player.global_position.y
				add_child(gene_targeted_bomb)
				Global.gene_targeted_bomb -= 1
				Global.show_tip(tr("GENETARGETEDBOMBLAUNCHED"))

func auto_bullet_buying():
	if Global.auto_bullet_buying:
		if Global.bullet_9mm <= 10 and Global.coin >= 60:
			Global.coin -= 60
			Global.bullet_9mm += 50
		if Global.bullet_762mm <= 10 and Global.coin >= 80:
			Global.coin -= 80
			Global.bullet_762mm += 50
		if Global.No12_bullet <= 10 and Global.coin >= 50:
			Global.coin -= 50
			Global.No12_bullet += 20
		if Global.shell <= 5 and Global.coin >= 50:
			Global.coin -= 50
			Global.shell += 30

func _on_walking_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.out_of_range = true

func _on_walking_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.out_of_range = false

func retry():
	Global.SpawnPath = $player/SpawnPath
	Global.pathFollow2D = $player/SpawnPath/PathFollow2D
