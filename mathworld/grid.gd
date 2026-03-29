extends Node2D

const DOT_SPACING = 40
const DOT_RADIUS = 1.5
const DOT_COLOR = Color(0.3, 0.3, 0.3)

func _ready():
	z_index = -1

func _process(_delta):
	queue_redraw()

func _draw():
	var size = get_viewport_rect().size
	var half = size / 2
	
	var player = get_tree().get_first_node_in_group("player")
	var offset = Vector2.ZERO
	if player:
		offset = Vector2(
			fmod(player.global_position.x, DOT_SPACING),
			fmod(player.global_position.y, DOT_SPACING)
		)
	
	var cols = int(size.x / DOT_SPACING) + 3
	var rows = int(size.y / DOT_SPACING) + 3
	
	for x in range(cols):
		for y in range(rows):
			draw_circle(
				Vector2(
					-half.x + x * DOT_SPACING - offset.x,
					-half.y + y * DOT_SPACING - offset.y
				),
				DOT_RADIUS,
				DOT_COLOR
			)
