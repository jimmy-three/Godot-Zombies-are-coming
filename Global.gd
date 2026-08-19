extends Node

var TipScene = preload("res://tip.tscn")

#int
var difficulty = 31
var zombie_spawn_interval = 3.5 - 0.035 * difficulty if difficulty < 100 else 0.1
var coin = INF
var max_life = 100
var bullet_9mm = 50
var bullet_762mm = 0
var No12_bullet = 0
var shell = 0
var bandage = 0
var energy_drinks = 0
var turrut = 0
var gene_targeted_bomb = 0
var player_move_type = 1
var shoot_sound_index = 1
#str
var prop_type = "bandage"
var language = "zh_CN0"
#bool
var BossSpawn = false
var CollisionHint = false
var auto_bullet_buying = false
var using_props = false
var out_of_range = false
var dead = false
#列表
var Bullet_list = [] #现显示的子弹
var Zombie_list = [] #现显示的僵尸
var laser_sight = [false, false] #[许可，开启状态]
#字典
#武器字典及其属性：[0许可，1基础伤害，2基础射击间隔，3基础击退，4子弹速度，5子弹偏移角度，6单次发射子弹量，7使用子弹，8音效]
var weapon = {"pistol" : [1, 80, 0.5, 50, 1000, 1, 1, "9mm", preload("res://resources/手枪射击音效.mp3")], 
"AK" : [0, 100, 0.15, 30, 1000, 2.5, 1, "9mm", preload("res://resources/冲锋枪射击音效.mp3")] , 
"gatlin" : [0, 100, 0.09, 20, 1000, 4, 1, "7.62mm", preload("res://resources/加特林射击音效.mp3")] , 
"shotgun" : [0, 25, 1.2, 25, 1000, 30, 10, "No12", preload("res://resources/霰弹枪射击音效.mp3")] , 
"sniper_gun" : [0, 550, 2.5, 150, 1500, 0.1, 1, "7.62mm", preload("res://resources/狙击枪射击音效.mp3")]}
var num_to_weapon = {0 : "pistol", 1 : "AK", 2 : "gatlin", 3 : "shotgun", 4 : "sniper_gun"}
var bullet_translation = {"bullet_9mm" : tr("SHELL9MM"), "bullet_762mm" : tr("SHELL762MM"), "No12_bullet" : tr("SHELL12")}
#其他
var pathFollow2D : PathFollow2D #zombie生成用路径
var SpawnPath : Path2D
var main : Node2D
var player

func _ready() -> void:
	get_tree().debug_collisions_hint = false
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func retry():
	difficulty = 1
	zombie_spawn_interval = 3.5 - 0.035 * difficulty if difficulty < 100 else 0.1
	coin = 100
	max_life = 100
	bullet_9mm = 50
	bullet_762mm = 0
	No12_bullet = 0
	shell = 0
	bandage = 0
	energy_drinks = 0
	turrut = 0
	gene_targeted_bomb = 0
	player_move_type = 1
	shoot_sound_index = 1
	prop_type = "bandage"
	BossSpawn = false
	CollisionHint = false
	auto_bullet_buying = false
	using_props = false
	out_of_range = false
	dead = false
	Bullet_list.clear()
	Zombie_list.clear()
	laser_sight = [false, false]
	weapon = {"pistol" : [1, 80, 0.5, 50, 1000, 1, 1, "9mm", preload("res://resources/手枪射击音效.mp3")], 
"AK" : [0, 100, 0.15, 30, 1000, 2.5, 1, "9mm", preload("res://resources/冲锋枪射击音效.mp3")] , 
"gatlin" : [0, 100, 0.09, 20, 1000, 4, 1, "7.62mm", preload("res://resources/加特林射击音效.mp3")] , 
"shotgun" : [0, 25, 1.2, 25, 1000, 30, 10, "No12", preload("res://resources/霰弹枪射击音效.mp3")] , 
"sniper_gun" : [0, 550, 2.5, 150, 1500, 0.1, 1, "7.62mm", preload("res://resources/狙击枪射击音效.mp3")]}

func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	if SpawnPath == null:
		return
	SpawnPath.rotation = -player.rotation
	Global.bullet_translation = {"bullet_9mm" : tr("SHELL9MM"), "bullet_762mm" : tr("SHELL762MM"), "No12_bullet" : tr("SHELL12")}

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		for i in range(1, 10):
			if event.keycode == KEY_1 + i - 1:
				switch_weapon(i - 1)

func show_tip(text : String):
	var Tip = TipScene.instantiate()
	Tip.get_node("CenterContainer").get_node("Text").text = text
	get_tree().current_scene.get_node("UI").add_child(Tip)

func switch_weapon(num):
	if num < 5 and num >= 0 and weapon[num_to_weapon[num]][0]:
		player.gun_type = num_to_weapon[num]
		player.get_node("gun").play(num_to_weapon[num] + str(weapon[num_to_weapon[num]][0]))
		player.get_node("gun").pause()

func language_update():
	var labels = get_tree().get_nodes_in_group("Unified_translated_labels")
	for label in labels:
		if label.has_meta("Key"):
			label.text = tr(label.get_meta("Key"))
	
	
	
	
