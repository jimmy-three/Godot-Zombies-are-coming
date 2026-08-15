extends Node

var bullet_pool = [] #子弹对象池

@export var bullet_scene = preload("res://bullet.tscn") 
@export var pool_size = 300

func _ready() -> void:
	for i in range(pool_size):
		var bullet = bullet_scene.instantiate()
		bullet.visible = false
		bullet.set_process(false)
		bullet.set_physics_process(false)
		bullet.add_to_group("bullets")
		bullet.get_node("CollisionShape2D").set_deferred("disabled", true)
		add_child(bullet)
		bullet_pool.append(bullet)

#子弹对象池代码
func get_bullet(damage):
	for bullet in bullet_pool:
		if not bullet.visible:
			bullet.add_to_group("bullets")
			bullet.visible = true
			bullet.get_node("AnimatedSprite2D").visible = true
			bullet.set_process(true)
			bullet.set_physics_process(true)
			bullet.get_node("CollisionShape2D").set_deferred("disabled", false)
			bullet.damage = damage
			return bullet
	var bullet = bullet_scene.instantiate()
	bullet.add_to_group("bullets")
	bullet.set_process(true)
	bullet.set_physics_process(true)
	bullet.add_to_group("bullets")
	bullet.get_node("CollisionShape2D").set_deferred("disabled", false)
	bullet.visible = true
	bullet.damage = damage
	add_child(bullet)	
	bullet_pool.append(bullet)
	return bullet

func return_bullet(bullet):
	bullet.remove_from_group("bullets")
	bullet.visible = false
	bullet.set_process(false)
	bullet.set_physics_process(false)
	bullet.direction = Vector2.ZERO
	bullet.position = Vector2.ZERO
	bullet.speed = 0
	bullet.get_node("CollisionShape2D").set_deferred("disabled", true)
