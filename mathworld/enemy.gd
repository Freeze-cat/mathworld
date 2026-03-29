extends CharacterBody2D

const SPEED = 90.0
var direction = Vector2.RIGHT
var timer = 0.0
var change_interval = 1.2
var in_battle = false
var inventory = [3, 5, 7, 2, 8]

func _ready():
	add_to_group("enemies")
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	collision_layer = 2
	collision_mask = 0

func _draw():
	var size = 28.0
	var half = size / 2
	
	# тень
	draw_rect(Rect2(-half + 2, -half + 3, size, size), Color(0, 0, 0, 0.3))
	
	# основное тело — тёмно-красное
	draw_rect(Rect2(-half, -half, size, size), Color(0.5, 0.05, 0.05))
	
	# диагональный градиент — три треугольника от тёмного к светлому
	# левый верхний угол светлее
	var tri1 = PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(-half, half)
	])
	draw_colored_polygon(tri1, Color(0.9, 0.2, 0.2, 0.7))
	
	# блик в верхнем левом углу
	var highlight = PackedVector2Array([
		Vector2(-half, -half),
		Vector2(-half + size * 0.5, -half),
		Vector2(-half, -half + size * 0.5)
	])
	draw_colored_polygon(highlight, Color(1, 0.4, 0.4, 0.5))

func _physics_process(_delta):
	timer += _delta
	if timer >= change_interval:
		timer = 0.0
		# 85% шанс идти к ближайшей цифре, 15% — бродить случайно
		if randf() < 0.85:
			var target = _find_nearest_number()
			if target:
				direction = (target.global_position - global_position).normalized()
			else:
				direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		else:
			direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	velocity = direction * SPEED
	move_and_slide()
	
	# подбираем цифры в радиусе 30 пикселей
	var numbers = get_tree().get_nodes_in_group("numbers")
	for num in numbers:
		if global_position.distance_to(num.global_position) < 30:
			inventory.append(num.value)
			num.queue_free()
			break
	
	if in_battle:
		return
	
	# проверяем столкновение с игроком
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) < 24:
		if not player.invulnerable:
			in_battle = true
			start_encounter()

func _find_nearest_number():
	# ищем ближайшую цифру на поле
	var numbers = get_tree().get_nodes_in_group("numbers")
	var nearest = null
	var nearest_dist = INF
	for num in numbers:
		var d = global_position.distance_to(num.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = num
	return nearest

func start_encounter():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		get_tree().paused = true
		var canvas = CanvasLayer.new()
		canvas.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(canvas)
		var battle_scene = load("res://battle.tscn")
		var battle = battle_scene.instantiate()
		canvas.add_child(battle)
		battle.setup(player.inventory, inventory.duplicate(), "comparison", 15.0)
		await battle.tree_exited
		in_battle = false
		if is_inside_tree():
			var p = get_tree().get_first_node_in_group("player")
			if p:
				p.set_invulnerable(3.0)
