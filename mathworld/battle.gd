extends Control

const CHALLENGE_PHRASES = [
	"Противник бросает вызов!",
	"Докажи, что умеешь считать.",
	"Он смотрит на тебя с презрением.",
	"Противник ухмыляется.",
	"Цифры не врут. Ты врёшь?",
	"Покажи на что способен.",
]

const WIN_PHRASES = [
	"Победа! Враг посрамлён.",
	"Ты победил. Математика на твоей стороне.",
	"Противник в шоке от твоих вычислений.",
	"Числа склонились перед тобой.",
]

const LOSE_PHRASES = [
	"Провал. Числа отвернулись от тебя.",
	"Проиграл. Математика беспощадна.",
	"Противник забрал своё. И твоё.",
	"Числа не простили ошибки.",
]

const FLEE_PHRASES = [
	"Сбежал. Числа запомнят это.",
	"Трусость — тоже стратегия.",
	"Ты ушёл. Враг доволен.",
]

var player_inventory = []
var enemy_inventory = []
var battle_started = false
var round_number = 0
var max_rounds = 3
var player_wins = 0
var enemy_wins = 0

var battle_type = "comparison"
var time_limit = 15.0
var time_left = 0.0
var timer_active = false

var correct_answer = 0
var operation = ""

# цифры которые игрок набирает для ответа
var current_digits = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var screen = get_viewport_rect().size
	
	$Background.size = screen
	$Background.color = Color(0, 0, 0, 0.92)
	
	$TimerLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$TimerLabel.position = Vector2(0, 20)
	$TimerLabel.size = Vector2(screen.x, 40)
	$TimerLabel.add_theme_font_size_override("font_size", 24)
	
	$EnemyLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$EnemyLabel.position = Vector2(0, 70)
	$EnemyLabel.size = Vector2(screen.x, 40)
	
	$ExpressionLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$ExpressionLabel.position = Vector2(0, screen.y * 0.3)
	$ExpressionLabel.size = Vector2(screen.x, 80)
	$ExpressionLabel.add_theme_font_size_override("font_size", 48)
	
	# текущий набираемый ответ
	$CurrentAnswerLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$CurrentAnswerLabel.position = Vector2(0, screen.y * 0.3 + 90)
	$CurrentAnswerLabel.size = Vector2(screen.x, 50)
	$CurrentAnswerLabel.add_theme_font_size_override("font_size", 32)
	$CurrentAnswerLabel.modulate = Color(1, 0.9, 0.3)
	
	$ResultLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$ResultLabel.position = Vector2(0, screen.y * 0.3 + 145)
	$ResultLabel.size = Vector2(screen.x, 40)
	$ResultLabel.add_theme_font_size_override("font_size", 20)
	
	$InventoryPanel.position = Vector2(screen.x * 0.1, screen.y * 0.72)
	$InventoryPanel.size = Vector2(screen.x * 0.8, 140)

func setup(p_inv: Array, e_inv: Array, b_type: String = "comparison", t_limit: float = 15.0):
	if battle_started:
		return
	battle_started = true
	player_inventory = p_inv.duplicate()
	enemy_inventory = e_inv.duplicate()
	battle_type = b_type
	time_limit = t_limit
	time_left = t_limit
	_new_round()

func _process(delta):
	if timer_active:
		time_left -= delta
		$TimerLabel.text = "⏱ %.1f" % time_left
		if time_left < 3.0:
			$TimerLabel.modulate = Color(1, 0.2, 0.2)
		else:
			$TimerLabel.modulate = Color(1, 1, 1)
		if time_left <= 0:
			timer_active = false
			_on_timeout()

func _new_round():
	round_number += 1
	time_left = time_limit
	timer_active = true
	current_digits = []
	$ResultLabel.text = ""
	$CurrentAnswerLabel.text = "→ _"
	$ExpressionLabel.modulate = Color(1, 1, 1)
	$EnemyLabel.text = CHALLENGE_PHRASES[randi() % CHALLENGE_PHRASES.size()]
	$EnemyLabel.text += "  |  Раунд %d из %d  |  Ты: %d  Враг: %d" % [round_number, max_rounds, player_wins, enemy_wins]
	
	if battle_type == "comparison":
		_setup_comparison_round()
	else:
		_setup_calculation_round()
	
	_build_player_grid()

func _setup_comparison_round():
	var condition_value = enemy_inventory[randi() % enemy_inventory.size()]
	var condition_type = ["больше", "меньше"][randi() % 2]
	operation = condition_type
	correct_answer = condition_value
	$ExpressionLabel.text = "? %s %d" % [condition_type, condition_value]

func _setup_calculation_round():
	var ops = ["+", "-"]
	operation = ops[randi() % ops.size()]
	var a = enemy_inventory[randi() % enemy_inventory.size()]
	var b = enemy_inventory[randi() % enemy_inventory.size()]
	if operation == "-" and a < b:
		var tmp = a; a = b; b = tmp
	if operation == "+":
		correct_answer = a + b
	else:
		correct_answer = a - b
	$ExpressionLabel.text = "%d %s %d = ?" % [a, operation, b]

func _build_player_grid():
	var grid = $InventoryPanel/PlayerGrid
	for child in grid.get_children():
		child.queue_free()
	
	for i in range(player_inventory.size()):
		var btn = Button.new()
		btn.text = str(player_inventory[i])
		btn.custom_minimum_size = Vector2(60, 60)
		btn.add_theme_font_size_override("font_size", 22)
		var idx = i
		btn.pressed.connect(func(): _on_digit_pressed(idx))
		grid.add_child(btn)
	
	# кнопка удалить последнюю цифру
	var del_btn = Button.new()
	del_btn.text = "⌫"
	del_btn.custom_minimum_size = Vector2(60, 60)
	del_btn.add_theme_font_size_override("font_size", 22)
	del_btn.pressed.connect(_on_delete_pressed)
	grid.add_child(del_btn)
	
	# кнопка подтвердить
	var confirm_btn = Button.new()
	confirm_btn.text = "✓"
	confirm_btn.custom_minimum_size = Vector2(60, 60)
	confirm_btn.add_theme_font_size_override("font_size", 22)
	confirm_btn.modulate = Color(0.3, 1, 0.3)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	grid.add_child(confirm_btn)
	
	# кнопка побега
	var flee_btn = Button.new()
	flee_btn.text = "Бежать"
	flee_btn.custom_minimum_size = Vector2(110, 60)
	flee_btn.pressed.connect(_on_flee)
	grid.add_child(flee_btn)

func _on_digit_pressed(idx: int):
	# добавляем цифру к текущему ответу
	if idx < player_inventory.size():
		current_digits.append(player_inventory[idx])
		_update_answer_label()

func _on_delete_pressed():
	# удаляем последнюю добавленную цифру
	if current_digits.size() > 0:
		current_digits.pop_back()
		_update_answer_label()

func _update_answer_label():
	if current_digits.is_empty():
		$CurrentAnswerLabel.text = "→ _"
	else:
		# собираем цифры в число: [1, 3, 7] → "137"
		var s = "→ "
		for d in current_digits:
			s += str(d)
		$CurrentAnswerLabel.text = s

func _on_confirm_pressed():
	if current_digits.is_empty():
		return
	
	# собираем число из цифр
	var number_str = ""
	for d in current_digits:
		number_str += str(d)
	var chosen = int(number_str)
	
	timer_active = false
	
	# анимация — число летит к примеру
	var flying = Label.new()
	flying.text = number_str
	flying.add_theme_font_size_override("font_size", 28)
	flying.modulate = Color(1, 0.9, 0.3)
	flying.position = $CurrentAnswerLabel.position + Vector2($CurrentAnswerLabel.size.x / 2, 0)
	add_child(flying)
	
	var target = $ExpressionLabel.position + Vector2($ExpressionLabel.size.x / 2, 20)
	var tween = create_tween()
	tween.tween_property(flying, "position", target, 0.35)
	tween.tween_property(flying, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_callback(flying.queue_free)
	await tween.finished
	
	# проверяем ответ
	var success = false
	if battle_type == "comparison":
		if operation == "больше" and chosen > correct_answer:
			success = true
		elif operation == "меньше" and chosen < correct_answer:
			success = true
	else:
		if chosen == correct_answer:
			success = true
	
	# вспышка примера
	var flash = create_tween()
	if success:
		flash.tween_property($ExpressionLabel, "modulate", Color(0.2, 1, 0.2), 0.15)
		flash.tween_property($ExpressionLabel, "modulate", Color(1, 1, 1), 0.4)
	else:
		var orig_x = $ExpressionLabel.position.x
		flash.tween_property($ExpressionLabel, "position:x", orig_x + 10, 0.05)
		flash.tween_property($ExpressionLabel, "position:x", orig_x - 10, 0.05)
		flash.tween_property($ExpressionLabel, "position:x", orig_x + 10, 0.05)
		flash.tween_property($ExpressionLabel, "position:x", orig_x, 0.05)
		flash.parallel().tween_property($ExpressionLabel, "modulate", Color(1, 0.2, 0.2), 0.1)
		flash.tween_property($ExpressionLabel, "modulate", Color(1, 1, 1), 0.3)
	await flash.finished
	
	# убираем использованные цифры из инвентаря
	for d in current_digits:
		var i = player_inventory.find(d)
		if i >= 0:
			player_inventory.remove_at(i)
	
	await _resolve_round(success)

func _on_timeout():
	$ResultLabel.text = "⌛ Время вышло!"
	await get_tree().create_timer(1.0).timeout
	enemy_wins += 1
	if player_inventory.size() > 0:
		var lost = player_inventory[randi() % player_inventory.size()]
		player_inventory.erase(lost)
		enemy_inventory.append(lost)
	await _check_end()

func _resolve_round(success: bool, idx: int = -1):
	if success:
		player_wins += 1
		$ResultLabel.text = "✓ Верно!"
		if enemy_inventory.size() > 0:
			var stolen = enemy_inventory[randi() % enemy_inventory.size()]
			enemy_inventory.erase(stolen)
			player_inventory.append(stolen)
	else:
		enemy_wins += 1
		$ResultLabel.text = "✗ Неверно."
		if idx >= 0 and idx < player_inventory.size():
			var lost = player_inventory[idx]
			player_inventory.remove_at(idx)
			enemy_inventory.append(lost)
	await get_tree().create_timer(1.5).timeout
	await _check_end()

func _check_end():
	if round_number >= max_rounds:
		if player_wins > enemy_wins:
			_end_battle(true)
		else:
			_end_battle(false)
	elif player_inventory.is_empty():
		_end_battle(false)
	elif enemy_inventory.is_empty():
		_end_battle(true)
	else:
		_new_round()

func _on_flee():
	timer_active = false
	$ResultLabel.text = FLEE_PHRASES[randi() % FLEE_PHRASES.size()]
	await get_tree().create_timer(1.0).timeout
	_end_battle(false)

func _end_battle(won: bool):
	timer_active = false
	if won:
		$ExpressionLabel.text = WIN_PHRASES[randi() % WIN_PHRASES.size()]
		# победитель забирает половину инвентаря врага
		var take_count = max(1, enemy_inventory.size() / 2)
		for i in range(take_count):
			if enemy_inventory.size() > 0:
				var stolen = enemy_inventory[randi() % enemy_inventory.size()]
				enemy_inventory.erase(stolen)
				player_inventory.append(stolen)
	else:
		$ExpressionLabel.text = LOSE_PHRASES[randi() % LOSE_PHRASES.size()]
		# проигравший теряет половину инвентаря
		var lose_count = max(1, player_inventory.size() / 2)
		for i in range(lose_count):
			if player_inventory.size() > 0:
				var lost = player_inventory[randi() % player_inventory.size()]
				player_inventory.erase(lost)
				enemy_inventory.append(lost)
	
	$ExpressionLabel.add_theme_font_size_override("font_size", 28)
	$ResultLabel.text = "%d : %d" % [player_wins, enemy_wins]
	
	await get_tree().create_timer(2.0).timeout
	
	var player = get_tree().get_first_node_in_group("player")
	player.inventory = player_inventory
	var inv = get_tree().get_first_node_in_group("inventory")
	if inv:
		inv.refresh(player_inventory)
	var enemy = get_tree().get_first_node_in_group("enemies")
	if enemy:
		enemy.inventory = enemy_inventory
	get_tree().paused = false
	get_parent().queue_free()
