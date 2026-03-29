extends Control

const PAUSE_PHRASES = [
	"Пауза. Числа никуда не денутся.",
	"Перерыв. Враг тоже устал.",
	"Пауза. Время попить кофеёк.",
	"Всё замерло. Даже математика.",
	"Пауза. Мир чисел ждёт твоего возвращения.",
	"Отдыхаем. Цифры терпеливы.",
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var screen = get_viewport_rect().size
	
	$Background.size = screen
	$Background.color = Color(0, 0, 0, 0.75)
	
	# центрируем layout
	$Layout.size = Vector2(300, 200)
	$Layout.position = Vector2((screen.x - 300) / 2, (screen.y - 200) / 2)
	
	# случайная фраза в заголовке
	$Layout/Title.text = PAUSE_PHRASES[randi() % PAUSE_PHRASES.size()]
	$Layout/Title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Layout/Title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Layout/Title.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	$Layout/ResumeButton.pressed.connect(_on_resume)
	$Layout/QuitButton.pressed.connect(_on_quit)

func _on_resume():
	get_tree().paused = false
	get_parent().queue_free()  # удаляем canvas вместе с меню

func _on_quit():
	get_tree().paused = false
	get_parent().queue_free()
	get_tree().change_scene_to_file("res://main_menu.tscn")
