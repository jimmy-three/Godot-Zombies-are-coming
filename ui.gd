extends CanvasLayer

var player : CharacterBody2D
var translate = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$PauseMenu/Language/LanguageOption.select(int(Global.language.substr(5,6)))
	TranslationServer.set_locale(Global.language.substr(0,5))
	$PauseMenu/LaserSight.text = tr("LOCKED")
	$PauseMenu/LaserSight.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3, 1.0))
	process_mode = Node.PROCESS_MODE_ALWAYS
	$PauseMenu.visible = false
	var Buttons = $PauseMenu/ScrollContainer.find_children("*", "Button")
	for button in Buttons:
		button.mouse_entered.connect(_on_mouse_hovered.bind(button))

func _process(_delta: float) -> void:
	if player and not translate:
		_on_language_option_item_selected(int(Global.language.substr(5,6)))
		translate = true
	#暂停
	if Input.is_action_just_pressed("pause") and not Global.dead:
		var tree = get_tree()
		tree.paused = !tree.paused
		player = tree.get_first_node_in_group("player")
		$PauseMenu.visible = tree.paused
		$PauseMenu/CharacterStatus/MaxLife.text = tr("MAXLIFE") + ":" + str(Global.max_life)
		$PauseMenu/CharacterStatus/Speed.text = tr("SPEED") + ":" + str(player.speed)
		$PauseMenu/CharacterStatus/Damage.text = tr("DAMAGEUP") + ":" + str(player.shoot_damage_up)
		$PauseMenu/CharacterStatus/ShootInterval.text = tr("SHOOTINTERVAL") + ":" + str(int(player.shoot_time_reduction * 100) * 0.01)
		$PauseMenu/CharacterStatus/Repel.text = tr("REPELUP") + ":" + str(player.repel_up)
		$Difficulty.text = tr("DIFFICULTY") + str(Global.difficulty)
		$Life.text = tr("LIFE") + str(player.life)
		$Coin.text = tr("COIN") + str(Global.coin)
		$LeftBullet.text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[player.needed_bullet],"num" : Global.get(player.needed_bullet)})
	if Input.is_action_just_pressed("switch_prop") and not Global.dead:
		Engine.time_scale = 0.1
		$PropSwitchPanel.visible = true
	if Input.is_action_just_released("switch_prop") and not Global.dead:
		Engine.time_scale = 1.0
		$PropSwitchPanel.visible = false

func _on_mouse_hovered(button : Button):
	var icon = button.icon
	$PauseMenu/PreviewBox.texture = icon
	$PauseMenu/CenterContainer/GoodName.text = button.get_meta("Name")
	$PauseMenu/CenterContainer2/GoodPrice.text = button.get_meta("Price") + tr("COINS")
	$PauseMenu/IntroductionScroller/Introduction.text = button.get_meta("Introduction")

func _on_sensitivity_slider_value_changed(value: float) -> void:
	$PauseMenu/Sensitivity/Value.text = str(int(value))
	if player != null:
		player.turn_speed = int(value)

func Purcasing(price : int):
	if Global.coin < price:
		Global.show_tip(tr("NOTENOUGHCOINS"))
		return false
	else:
		Global.show_tip(tr("PURCHASED"))
		Global.coin -= price
		$Coin.text = tr("COIN") + str(Global.coin)
		$PauseMenu/CenterContainer/GoodName.text = ""
		$PauseMenu/CenterContainer2/GoodPrice.text = "0" + tr("COINS")
		$PauseMenu/IntroductionScroller/Introduction.text = ""
		$PauseMenu/PreviewBox.texture = preload("res://resources/已售罄.png")
		return true

func _on_damage_up_pressed() -> void:
	if Purcasing(30):
		player.shoot_damage_up += 10
		$PauseMenu/CharacterStatus/Damage.text = tr("DAMAGEUP") + ":" + str(player.shoot_damage_up)

func _on_shoot_speed_up_pressed() -> void:
	if player.shoot_time_reduction > pow(0.9, 25) and Purcasing(40):
		player.shoot_time_reduction *= 0.9
		$PauseMenu/CharacterStatus/ShootInterval.text = tr("SHOOTINTERVAL") + ":" + str(int(player.shoot_time_reduction * 100) * 0.01)
		if player.shoot_time_reduction <= pow(0.9, 25):
			$PauseMenu/ScrollContainer/GoodsList/Plus/ShootSpeedUp.icon = preload("res://resources/已售罄.png")
			$PauseMenu/ScrollContainer/GoodsList/Plus/ShootSpeedUp.set_meta("Price", "0")
			$PauseMenu/ScrollContainer/GoodsList/Plus/ShootSpeedUp.set_meta("Name", "")
			$PauseMenu/ScrollContainer/GoodsList/Plus/ShootSpeedUp.set_meta("Introduction", "")

func _on_repel_up_pressed() -> void:
	if Purcasing(30):
		player.repel_up += 10
		$PauseMenu/CharacterStatus/Repel.text = tr("REPELUP") + ":" + str(player.repel_up)

func _on_speed_up_pressed() -> void:
	if Purcasing(30):
		player.speed += 10
		$PauseMenu/CharacterStatus/Speed.text = tr("SPEED") + ":" + str(player.speed)

func _on_life_up_pressed() -> void:
	if Purcasing(30):
		Global.max_life += 10
		player.life += 10
		$PauseMenu/CharacterStatus/MaxLife.text = tr("MAXLIFE") + ":" + str(Global.max_life)
		$Life.text = tr("LIFE") + str(player.life)

func _on_9mm_bullet_pressed() -> void:
	if Purcasing(60):
		Global.bullet_9mm += 50
		$LeftBullet.text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[player.needed_bullet],"num" : Global.get(player.needed_bullet)})	

func _on_762mm_bullet_pressed() -> void:
	if Purcasing(80):
		Global.bullet_762mm += 50
		$LeftBullet.text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[player.needed_bullet],"num" : Global.get(player.needed_bullet)})	

func _on_no_12_bullet_pressed() -> void:
	if Purcasing(50):
		Global.No12_bullet += 20
		$LeftBullet.text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[player.needed_bullet],"num" : Global.get(player.needed_bullet)})	

func _on_shell_pressed() -> void:
	if Purcasing(50):
		Global.shell += 30

func _on_auto_bullet_buying_pressed() -> void:
	if not Global.auto_bullet_buying and Purcasing(100):
		Global.auto_bullet_buying = true
		$PauseMenu/ScrollContainer/GoodsList/Bullet/AutoBulletBuying.icon = preload("res://resources/已售罄.png")
		$PauseMenu/ScrollContainer/GoodsList/Bullet/AutoBulletBuying.set_meta("Price", "0")
		$PauseMenu/ScrollContainer/GoodsList/Bullet/AutoBulletBuying.set_meta("Name", "")
		$PauseMenu/ScrollContainer/GoodsList/Bullet/AutoBulletBuying.set_meta("Introduction", "")

func _on_ak_pressed() -> void:
	if not Global.weapon["AK"][0] and Purcasing(80):
		Global.weapon["AK"][0] = 1
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.icon = preload("res://resources/三头AK图标.png")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Name", tr("SUBMACHINEGUN2"))
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Introduction", tr("SUBMACHINEGUN2INTRODUCTION"))
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Price", "120")
		Global.switch_weapon(1)
	elif Global.weapon["AK"][0] == 1 and Purcasing(120):
		Global.weapon["AK"][0] = 2
		Global.weapon["AK"][1] = 80
		Global.weapon["AK"][2] = 0.225
		Global.weapon["AK"][3] = 20
		Global.weapon["AK"][5] = 5
		Global.weapon["AK"][6] = 3
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.icon = preload("res://resources/已售罄.png")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Price", "0")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Name", "")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Introduction", "")
		Global.switch_weapon(1)

func _on_gatlin_pressed() -> void:
	if not Global.weapon["gatlin"][0] and Purcasing(200):
		Global.weapon["gatlin"][0] = 1
		$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.icon = preload("res://resources/狂暴加特林图标.png")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.set_meta("Name", tr("GATLIN2"))
		$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.set_meta("Introduction", tr("GATLIN2INTRODUCTION"))
		Global.switch_weapon(2)
	elif Global.weapon["gatlin"][0] == 1 and Purcasing(200):
		Global.weapon["gatlin"][0] = 2
		Global.weapon["gatlin"][2] = 0.06
		Global.weapon["gatlin"][5] = 3.5
		Global.weapon["gatlin"][6] = 2
		$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.icon = preload("res://resources/已售罄.png")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.set_meta("Price", "0")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.set_meta("Name", "")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.set_meta("Introduction", "")
		Global.switch_weapon(2)

func _on_shot_gun_pressed() -> void:
	if not Global.weapon["shotgun"][0] and Purcasing(130):
		Global.weapon["shotgun"][0] = 1
		$PauseMenu/ScrollContainer/GoodsList/Weapon/ShotGun.icon = preload("res://resources/已售罄.png")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/ShotGun.set_meta("Price", "0")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/ShotGun.set_meta("Name", "")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/ShotGun.set_meta("Introduction", "")
		Global.switch_weapon(3)


func _on_sniper_gun_pressed() -> void:
	if not Global.weapon["sniper_gun"][0] and Purcasing(100):
		Global.weapon["sniper_gun"][0] = 1
		$PauseMenu/ScrollContainer/GoodsList/Weapon/SniperGun.icon = preload("res://resources/已售罄.png")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/SniperGun.set_meta("Price", "0")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/SniperGun.set_meta("Name", "")
		$PauseMenu/ScrollContainer/GoodsList/Weapon/SniperGun.set_meta("Introduction", "")
		Global.switch_weapon(4)

func _on_bandage_pressed() -> void:
	if Purcasing(20):
		Global.bandage += 1

func _on_eneygy_drinks_pressed() -> void:
	if Purcasing(30):
		Global.energy_drinks += 1

func _on_precise_pressed() -> void:
	if not Global.laser_sight[0] and Purcasing(50):
		Global.laser_sight[0] = 1
		Global.laser_sight[1] = true
		$PauseMenu/LaserSight.text = tr("LASERSIGHT")
		$PauseMenu/LaserSight.set_meta("Key" , "LASERSIGHT")
		$PauseMenu/LaserSight.add_theme_color_override("font_color", Color.BLACK)
		$PauseMenu/LaserSight/LaserCheckBox.button_pressed = true
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.icon = preload("res://resources/精准射击.png")
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Price", "120")
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Name", tr("PRECISE2"))
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Introduction", tr("PRECISE2INTRODUCTION"))
	elif Global.laser_sight[0] == 1 and Purcasing(120):
		Global.laser_sight[0] = 2
		Global.player_move_type = 2
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.icon = preload("res://resources/已售罄.png")
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Price", "0")
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Name", "")
		$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Introduction", "")

func _on_turrut_pressed() -> void:
	if Purcasing(300):
		Global.turrut += 1

func _on_gene_targeted_bomb_pressed() -> void:
	if Purcasing(1000):
		Global.gene_targeted_bomb += 1

func _on_switch_bandage_pressed() -> void:
	Global.show_tip(tr("PROPSWITCHED"))
	Global.prop_type = "bandage"
	$TouchScreen/touch_screen_use_prop.texture_normal = load("res://resources/绷带.png")

func _on_switch_energy_drinks_pressed() -> void:
	Global.show_tip(tr("PROPSWITCHED"))
	Global.prop_type = "energy_drinks"
	$TouchScreen/touch_screen_use_prop.texture_normal = load("res://resources/夯大力饮料.png")

func _on_switch_turrut_pressed() -> void:
	Global.show_tip(tr("PROPSWITCHED"))
	Global.prop_type = "turrut"
	$TouchScreen/touch_screen_use_prop.texture_normal = load("res://resources/炮台图标.png")

func _on_switch_gene_targeted_bomb_pressed() -> void:
	Global.show_tip(tr("PROPSWITCHED"))
	Global.prop_type = "gene_targeted_bomb"
	$TouchScreen/touch_screen_use_prop.texture_normal = load("res://resources/导弹图标.png")

func _on_laser_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if not Global.laser_sight[0]:
			$PauseMenu/LaserSight/LaserCheckBox.set_pressed_no_signal(false)
		else:
			Global.laser_sight[1] = true
	else:
		Global.laser_sight[1] = false

func _on_retry_pressed() -> void:
	var tree = get_tree()
	tree.paused = false
	for zombie in Global.Zombie_list:
		ZombiePool.return_zombie(zombie)
	for bullet in get_tree().get_nodes_in_group("bullets"):
		BulletPool.return_bullet(bullet)
	Global.retry()
	get_tree().reload_current_scene()
	$"..".retry()

func _on_language_option_item_selected(index: int) -> void:
	if index == 0:
		TranslationServer.set_locale("zh_CN")
		Global.language = "zh_CN0"
	elif index == 1:
		TranslationServer.set_locale("en_US")
		Global.language = "en_US1"
	elif index == 2:
		TranslationServer.set_locale("ja_JP")
		Global.language = "ja_JP2"
	Global.bullet_translation = {"bullet_9mm" : tr("SHELL9MM"), "bullet_762mm" : tr("SHELL762MM"), "No12_bullet" : tr("SHELL12")}
	Global.language_update()
	$Difficulty.text = tr("DIFFICULTY") + str(Global.difficulty)
	$Life.text = tr("LIFE") + str(player.life)
	$Coin.text = tr("COIN") + str(Global.coin)
	$LeftBullet.text = tr("LEFTBULLETS").format({"name" : Global.bullet_translation[player.needed_bullet],"num" : Global.get(player.needed_bullet)})
	$PauseMenu/CharacterStatus/MaxLife.text = tr("MAXLIFE") + ":" + str(Global.max_life)
	$PauseMenu/CharacterStatus/Speed.text = tr("SPEED") + ":" + str(player.speed)
	$PauseMenu/CharacterStatus/Damage.text = tr("DAMAGEUP") + ":" + str(player.shoot_damage_up)
	$PauseMenu/CharacterStatus/ShootInterval.text = tr("SHOOTINTERVAL") + ":" + str(int(player.shoot_time_reduction * 100) * 0.01)
	$PauseMenu/CharacterStatus/Repel.text = tr("REPELUP") + ":" + str(player.repel_up)
	$PauseMenu/Quit.text = tr("QUIT")
	$TouchScreen/touch_screen_switch_prop/CenterContainer/Label.text = tr("SWITCHPROP")
	
	$PauseMenu/ScrollContainer/GoodsList/Plus/DamageUp.set_meta("Name", tr("DAMAGEUP"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/DamageUp.set_meta("Introduction", tr("DAMAGEUPINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/ShootSpeedUp.set_meta("Name", tr("SHOOTSPEEDUP"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/ShootSpeedUp.set_meta("Introduction", tr("SHOOTSPEEDUPINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/RepelUp.set_meta("Name", tr("REPELUP"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/RepelUp.set_meta("Introduction", tr("REPELUPINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/SpeedUp.set_meta("Name", tr("SPEEDUP"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/SpeedUp.set_meta("Introduction", tr("SPEEDUPINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/LifeUp.set_meta("Name", tr("LIFEUP"))
	$PauseMenu/ScrollContainer/GoodsList/Plus/LifeUp.set_meta("Introduction", tr("LIFEUPINTRODUCTION"))
	
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/9mmBullet".set_meta("Name", tr("SHELL9MM"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/9mmBullet".set_meta("Introduction", tr("SHELL9MMINTRODUCTION"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/762mmBullet".set_meta("Name", tr("SHELL762MM"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/762mmBullet".set_meta("Introduction", tr("SHELL762MMINTRODUCTION"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/No12Bullet".set_meta("Name", tr("SHELL12"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/No12Bullet".set_meta("Introduction", tr("SHELL12INTRODUCTION"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/Shell".set_meta("Name", tr("SHELL"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/Shell".set_meta("Introduction", tr("SHELLINTRODUCTION"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/AutoBulletBuying".set_meta("Name", tr("AUTOBULLETBUYING"))
	$"PauseMenu/ScrollContainer/GoodsList/Bullet/AutoBulletBuying".set_meta("Introduction", tr("AUTOBULLETBUYINGINTRODUCTION"))
	
	$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Name", tr("SUBMACHINEGUN" + str(Global.weapon["AK"][0] + 1)))
	$PauseMenu/ScrollContainer/GoodsList/Weapon/AK.set_meta("Introduction", tr("SUBMACHINEGUN" + str(Global.weapon["AK"][0] + 1) + "INTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.set_meta("Name", tr("GATLIN" + str(Global.weapon["gatlin"][0] + 1)))
	$PauseMenu/ScrollContainer/GoodsList/Weapon/Gatlin.set_meta("Introduction", tr("GATLIN" + str(Global.weapon["gatlin"][0] + 1) + "INTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Weapon/ShotGun.set_meta("Name", tr("SHOTGUN" + str(Global.weapon["shotgun"][0] + 1)))
	$PauseMenu/ScrollContainer/GoodsList/Weapon/ShotGun.set_meta("Introduction", tr("SHOTGUN" + str(Global.weapon["shotgun"][0] + 1) + "INTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Weapon/SniperGun.set_meta("Name", tr("SNIPERGUN" + str(Global.weapon["sniper_gun"][0] + 1)))
	$PauseMenu/ScrollContainer/GoodsList/Weapon/SniperGun.set_meta("Introduction", tr("SNIPERGUN" + str(Global.weapon["sniper_gun"][0] + 1) + "INTRODUCTION"))

	$PauseMenu/ScrollContainer/GoodsList/Prop/Bandage.set_meta("Name", tr("BANDAGE"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/Bandage.set_meta("Introduction", tr("BANDAGEINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/EneygyDrinks.set_meta("Name", tr("ENERGYDRINKS"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/EneygyDrinks.set_meta("Introduction", tr("ENERGYDRINKSINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Name", tr("PRECISE"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/Precise.set_meta("Introduction", tr("PRECISEINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/Turrut.set_meta("Name", tr("TURRUT"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/Turrut.set_meta("Introduction", tr("TURRUTINTRODUCTION"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/GeneTargetedBomb.set_meta("Name", tr("GENETARGETEDBOMB"))
	$PauseMenu/ScrollContainer/GoodsList/Prop/GeneTargetedBomb.set_meta("Introduction", tr("GENETARGETEDBOMBINTRODUCTION"))

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_damage_display_check_button_toggled(toggled_on: bool) -> void:
	Global.damage_display = toggled_on
