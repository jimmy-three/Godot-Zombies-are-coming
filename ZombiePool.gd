extends Node

var zombie_pool = [] #僵尸对象池

@export var zombie_scene = preload("res://zombie.tscn") 
@export var pool_size = 300

func _ready() -> void:
	for i in range(pool_size):
		var zombie = zombie_scene.instantiate()
		zombie.visible = false
		zombie.set_process(false)
		zombie.set_physics_process(false)
		zombie.get_node("CollisionShape2D").set_deferred("disabled", true)
		add_child(zombie)
		zombie_pool.append(zombie)

#僵尸对象池代码
func get_zombie():
	for zombie in zombie_pool:
		if not zombie.visible:
			zombie.visible = true
			zombie.set_process(true)
			zombie.set_physics_process(true)
			zombie.get_node("CollisionShape2D").set_deferred("disabled", false)
			zombie.add_to_group("enemies")
			return zombie
	return null

func return_zombie(zombie):
	zombie.remove_from_group("enemies")
	zombie.visible = false
	zombie.set_process(false)
	zombie.set_physics_process(false)
	zombie.direction = Vector2.ZERO
	zombie.position = Vector2.ZERO
	zombie.speed = 0
	zombie.life = 100
	zombie.type = 1
	zombie.get_node("CollisionShape2D").set_deferred("disabled", true)
