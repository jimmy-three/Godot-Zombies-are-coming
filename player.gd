extends CharacterBody2D
@export var life = 100 
@export var speed = 200 #移动速度
var speed_multiplier = 1 #移动速度倍率
var shoot_time_reduction = 1 #增益攻击间隔
var repel_up = 0
var turn_speed = 2 #转向速度
var shoot_damage_up = 0 #增益子弹伤害
var gun_expected_distance = 26 #枪的期望相对距离
var gun_distance = gun_expected_distance #枪的实际相对距离
var gun_relative_pos = Vector2(1, 0) * gun_distance #枪的相对位置
var gun_type = "pistol"
var can_shoot = true
var randomizer = RandomNumberGenerator.new()
var needed_bullet = "bullet_9mm"

func _ready() -> void:
	$gun.play("pistol1")
	add_to_group("player")
	$"../UI/LeftBullet".text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[needed_bullet],"num" : Global.get(needed_bullet)})

func _process(delta: float) -> void:
	#速度倍率调整
	speed_multiplier = 1.0
	if Global.using_props:
		speed_multiplier *= 0.5
	if $"../SpeedUpTimer".time_left > 0:
		speed_multiplier *= 1.5
	#射击
	match Global.weapon[gun_type][7]:
		"9mm":
			needed_bullet = "bullet_9mm"
		"7.62mm":
			needed_bullet = "bullet_762mm"
		"No12":
			needed_bullet = "No12_bullet"
	$"../UI/LeftBullet".text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[needed_bullet],"num" : Global.get(needed_bullet)})
	if Input.is_action_pressed("shoot"):
		check_shoot(needed_bullet)
	if Input.is_action_just_released("shoot"):
		$gun.pause()
	#是否出圈
	if Global.out_of_range:
		life -= int(0.01 * Global.max_life)
	gun_positioning()
	walk(delta)
	queue_redraw()

func _draw() -> void:
	if Global.laser_sight[1] or gun_type == "sniper_gun":
		var start = to_local($gun/Marker2D.global_position)
		draw_line(start, start + Vector2.RIGHT * 100000, Color.RED, 1.0)

func walk(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed * speed_multiplier
	move_and_slide()
	if Global.player_move_type == 1:
		if Input.is_action_pressed("turn_right"):
			rotation += turn_speed * delta
		if Input.is_action_pressed("turn_left"):
			rotation -= turn_speed * delta
	elif Global.player_move_type == 2:
		var mouse_pos = get_global_mouse_position()
		look_at(mouse_pos)

func shoot():
	$gun.play(gun_type + str(Global.weapon[gun_type][0]))
	randomizer.randomize()
	#音效
	var ShootSound = get_node("ShootSound" + str(Global.shoot_sound_index))
	ShootSound.stream = Global.weapon[gun_type][8]
	ShootSound.play()
	Global.shoot_sound_index = (Global.shoot_sound_index + 1) % 6
	for i in range(Global.weapon[gun_type][6]):
		var bullet = BulletPool.get_bullet(Global.weapon[gun_type][1] + shoot_damage_up)
		var offset = deg_to_rad(randomizer.randf_range(-Global.weapon[gun_type][5], Global.weapon[gun_type][5]))
		bullet.direction = Vector2.RIGHT.rotated(rotation + offset)
		bullet.rotation = rotation + offset
		bullet.global_position = $gun.global_position
		bullet.speed = Global.weapon[gun_type][4]
		bullet.repel = Global.weapon[gun_type][3] + repel_up
		bullet._ready()
		Global.Bullet_list.append(bullet)
	can_shoot = false
	$ShootTimer.start(max(Global.weapon[gun_type][2] * shoot_time_reduction, 0.02) * (1 + 0.5 * int(Global.using_props)))
	gun_distance = 23

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func gun_positioning():
	gun_relative_pos = Vector2(1, 0) * gun_distance
	$gun.position = gun_relative_pos
	if gun_distance < gun_expected_distance:
		gun_distance += 0.5
	elif gun_distance > gun_expected_distance:
		gun_distance -= 0.5

func take_damage(damage):
	life -= damage

func check_shoot(ammo_key : String):
	if Global.get(ammo_key) > 0:
		if can_shoot:
			shoot()
			Global.set(ammo_key, Global.get(ammo_key) - 1)
	elif $BulletTipTimer.time_left == 0:
		Global.show_tip(tr("NOTENOUGHBULLETS"))
		$BulletTipTimer.start(0.5)
