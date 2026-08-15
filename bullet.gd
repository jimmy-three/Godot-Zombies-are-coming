extends Area2D

var direction = Vector2.RIGHT
var speed = 1500 #移动速度
var _prev_pos = Vector2.RIGHT
var damage = 100
var repel = 50
var bullet_type = "normal"
var RayQuery = true
var is_exploding = false
var explosion_alpha = 0.0

func _ready() -> void:
	reset()

func _process(delta: float) -> void:
	fly(delta)

func reset():
	_prev_pos = global_position
	if bullet_type == "shell":
		scale = Vector2(1.3, 1.5)
		$CollisionShape2D.scale = Vector2(1.3, 1.5)

func fly(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if visible:
		$ExistTimer.start()

func _physics_process(delta: float) -> void:
	if RayQuery:
		if _prev_pos.distance_squared_to(global_position) < 1.0:
			return
		var next_pos = global_position + (global_position - _prev_pos).normalized() * speed * delta
		var space = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(_prev_pos, next_pos, 0x4)
		query.collide_with_areas = true
		query.exclude = [self]
		var result = space.intersect_ray(query)
		if not result.is_empty():
			var hit_object = result["collider"]
			if hit_object.has_method("take_damage"):
				hit_object.take_damage(damage, repel)
			Global.Bullet_list.erase(self)
			BulletPool.return_bullet(self)
			return
		_prev_pos = global_position

func _on_exist_timer_timeout() -> void:
	Global.Bullet_list.erase(self)
	BulletPool.return_bullet(self)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and area.has_method("take_damage") and area.visible:
		area.take_damage(damage, repel)
		Global.Bullet_list.erase(self)
		BulletPool.return_bullet(self)
