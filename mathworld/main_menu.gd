extends Control

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_start()

func _ready():
	var screen = get_viewport_rect().size
	
	$Background.size = screen
	$Background.color = Color(0, 0, 0, 1)
	
	# размер и центрирование layout
	$Layout.size = Vector2(300, 200)
	$Layout.position = Vector2((screen.x - 300) / 2, (screen.y - 200) / 2)
	
	# выравнивание текста по центру
	$Layout/Title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Layout/Title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Layout/Subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Layout/Subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	$Layout/StartButton.pressed.connect(_on_start)
	$Layout/QuitButton.pressed.connect(_on_quit)

func _on_start():
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit():
	get_tree().quit()
