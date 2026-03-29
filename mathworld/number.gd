extends Area2D

var value = 1

func setup(v: int):
	value = v
	$Label.text = str(v)

func _ready():
	$Label.text = str(value)
	body_entered.connect(_on_body_entered)
	add_to_group("numbers")

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.collect_number(value)
		get_tree().get_root().get_node("World").register_picked_position(global_position)
		queue_free()
