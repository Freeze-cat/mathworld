extends CharacterBody2D

const SPEED = 70.0
var direction = Vector2.RIGHT
var timer = 0.0
var change_interval = 1.5
var in_battle = false
var inventory = [2, 4, 6, 3, 5]

# тип боя который этот враг использует
var battle_type = "calculation"
# сложность — время на ответ
var time_limit = 10.0

func _ready():
	add_to_group("enemies")
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	collision_layer = 2
	collision_mask = 0

func _draw():
	# рисуем ромб
	var size = 18.0
	var points = PackedVector2Array([
		Vector2(0, -size),   # верх
		Vector2(size, 0),    # право
		Vector2(0, size),    # низ
		Vector2(-size, 0),   # лево
	])
	
	# тень
	var shadow = PackedVector2Array([
		Vector2(2, -size + 3),
		Vector2(size + 2, 3),
		Vector2(2, size + 3),
		Vector2(-size + 2, 3),
	])
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.3))
	
	# основное тело тёмно-жёлтое
	draw_colored_polygon(points, Color(0.7, 0.6, 0.0))
	
	# диагональный блик
	var highlight = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size * 0.5, -size * 0.2),
		Vector2(0, 0),
		Vector2(-size * 0.5, -size * 0.2),
	])
	draw_colored_polygon(highlight, Color(1, 0.95, 0.3, 0.6))

func _physics_process(_delta):
	timer += _delta
	if timer >= change_interval:
		timer = 0.0
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
	
	# подбираем цифры
	var numbers = get_tree().get_nodes_in_group("numbers")
	for num in numbers:
		if global_position.distance_to(num.global_position) < 30:
			inventory.append(num.value)
			num.queue_free()
			break
	
	if in_battle:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) < 24:
		if not player.invulnerable:
			in_battle = true
			start_encounter()

func _find_nearest_number():
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
		# передаём тип боя и лимит времени
		battle.setup(player.inventory, inventory.duplicate(), battle_type, time_limit)
		await battle.tree_exited
		in_battle = false
		if is_inside_tree():
			var p = get_tree().get_first_node_in_group("player")
			if p:
				p.set_invulnerable(3.0)
