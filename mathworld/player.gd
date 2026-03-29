extends CharacterBody2D

const SPEED = 200.0
var inventory = []
var invulnerable = false

# переменные для анимации формы
var squash = 1.0
var stretch = 1.0
var was_moving = false

func _input(event):
	if event.is_action_pressed("ui_cancel") or (get_tree().paused and event.is_action_pressed("ui_accept")):
		if get_tree().paused:
			get_tree().paused = false
			var pause = get_tree().get_first_node_in_group("pause_menu")
			if pause:
				pause.get_parent().queue_free()
		else:
			get_tree().paused = true
			var canvas = CanvasLayer.new()
			canvas.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(canvas)
			var pause = load("res://pause_menu.tscn").instantiate()
			canvas.add_child(pause)

func _ready():
	add_to_group("player")
	z_index = 1
	collision_layer = 1
	collision_mask = 1
	process_mode = Node.PROCESS_MODE_ALWAYS  # добавь эту строчку

func _draw():
	var points = 32
	var radius = 16.0
	
	# основное тело
	var poly = PackedVector2Array()
	for i in range(points):
		var angle = (float(i) / points) * TAU
		poly.append(Vector2(
			cos(angle) * radius * stretch,
			sin(angle) * radius * squash
		))
	
	# тень — смещённый тёмный круг снизу
	var shadow = PackedVector2Array()
	for i in range(points):
		var angle = (float(i) / points) * TAU
		shadow.append(Vector2(
			cos(angle) * radius * stretch + 2,
			sin(angle) * radius * squash + 3
		))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.3))
	
	# основное тело — светло-серое
	draw_colored_polygon(poly, Color(0.85, 0.85, 0.85))
	
	# верхняя половина светлее — имитация градиента
	var top_poly = PackedVector2Array()
	for i in range(points):
		var angle = (float(i) / points) * TAU
		if sin(angle) < 0:
			top_poly.append(Vector2(
				cos(angle) * radius * stretch,
				sin(angle) * radius * squash
			))
	if top_poly.size() >= 3:
		draw_colored_polygon(top_poly, Color(1, 1, 1, 0.5))
	
	# блик — маленький кружок сверху-слева
	var highlight = PackedVector2Array()
	var h_points = 16
	for i in range(h_points):
		var angle = (float(i) / h_points) * TAU
		highlight.append(Vector2(
			cos(angle) * radius * 0.3 * stretch - 6,
			sin(angle) * radius * 0.3 * squash - 6
		))
	draw_colored_polygon(highlight, Color(1, 1, 1, 0.9))

func _physics_process(_delta):
	if get_tree().paused:
		return
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	var is_moving = direction != Vector2.ZERO
	
		# деформация при старте движения
	if is_moving and not was_moving:
		squash = 0.75
		stretch = 1.25
	# деформация при остановке
	elif not is_moving and was_moving:
		squash = 1.2
		stretch = 0.85
	# деформация при смене направления
	elif is_moving and was_moving:
		var old_vel = velocity.normalized()
		var new_vel = direction.normalized()
		var angle_diff = old_vel.angle_to(new_vel)
		if abs(angle_diff) > 0.5:  # если угол поворота заметный
			squash = 0.85
			stretch = 1.15
	
	# плавное возвращение к нормальной форме
	squash = lerp(squash, 1.0, 0.2)
	stretch = lerp(stretch, 1.0, 0.2)
	
	was_moving = is_moving
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	move_and_slide()
	queue_redraw()  # перерисовываем каждый кадр для анимации

func collect_number(v: int):
	inventory.append(v)
	var inv = get_tree().get_first_node_in_group("inventory")
	if inv:
		inv.add_item(v)

func set_invulnerable(duration: float):
	invulnerable = true
	await get_tree().create_timer(duration).timeout
	invulnerable = false

func update_hud():
	pass
