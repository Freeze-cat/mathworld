extends Control

const SLOT_SIZE = 52

func _ready():
	visible = false
	var button = get_tree().get_first_node_in_group("inventory_button")
	if button:
		button.pressed.connect(_toggle)

func _toggle():
	visible = !visible

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		_toggle()

func add_item(value: int):
	# ищем существующий слот с таким числом
	var grid = $Panel/Grid
	for slot in grid.get_children():
		if slot.get_meta("value") == value:
			# увеличиваем счётчик
			var count = slot.get_meta("count") + 1
			slot.set_meta("count", count)
			slot.get_node("Count").text = str(count)
			return
	
	# создаём новый слот
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	slot.set_meta("value", value)
	slot.set_meta("count", 1)
	
	# большая цифра по центру
	var label = Label.new()
	label.name = "Value"
	label.text = str(value)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(label)
	
	# маленький счётчик в правом нижнем углу
	var count_label = Label.new()
	count_label.name = "Count"
	count_label.text = "1"
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	count_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	count_label.add_theme_font_size_override("font_size", 10)
	count_label.modulate = Color(0.5, 0.9, 0.5)  # зелёный цвет
	count_label.offset_right = -3
	count_label.offset_bottom = -3
	slot.add_child(count_label)
	
	grid.add_child(slot)

func refresh(new_inventory: Array):
	# очищаем и перерисовываем
	for child in $Panel/Grid.get_children():
		child.queue_free()
	for v in new_inventory:
		add_item(v)
