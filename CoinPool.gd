extends Node

var coin_pool = [] #子弹对象池

@export var coin_scene = preload("res://coin.tscn") 
@export var pool_size = 300

func _ready() -> void:
	for i in range(pool_size):
		var coin = coin_scene.instantiate()
		coin.visible = false
		coin.set_process(false)
		coin.set_physics_process(false)
		coin.add_to_group("coins")
		coin.get_node("CollisionShape2D").set_deferred("disabled", true)
		add_child(coin)
		coin_pool.append(coin)

#子弹对象池代码
func get_coin():
	for coin in coin_pool:
		if not coin.visible:
			coin.reset()
			coin.visible = true
			coin.set_process(true)
			coin.set_physics_process(true)
			coin.get_node("CollisionShape2D").set_deferred("disabled", false)
			coin.add_to_group("coins")
			return coin
	var coin = coin_scene.instantiate()
	coin.visible = true
	coin.set_process(true)
	coin.set_physics_process(true)
	coin.add_to_group("coins")
	coin.get_node("CollisionShape2D").set_deferred("disabled", false)
	add_child(coin)	
	coin_pool.append(coin)
	return coin

func return_coin(coin):
	coin.remove_from_group("coins")
	coin.visible = false
	coin.set_process(false)
	coin.set_physics_process(false)
	coin.direction = Vector2.ZERO
	coin.position = Vector2.ZERO
	coin.get_node("CollisionShape2D").set_deferred("disabled", true)
	coin.get_node("ScatterTimer").stop()
