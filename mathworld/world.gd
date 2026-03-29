extends Node2D

@export var number_scene: PackedScene
@export var enemy_scene: PackedScene
@export var enemy2_scene: PackedScene

var spawn_radius_min = 700
var spawn_radius_max = 900
var min_distance_between = 80
var check_interval = 1.0
var numbers_per_spawn = 8
var timer = 0.0
var explored_chunks = {}
var chunk_size = 300
var used_positions = []

func get_chunk(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / chunk_size), floor(pos.y / chunk_size))

func _ready():
	spawn_numbers_around(Vector2.ZERO, 20, 100, 500)
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = Vector2(200, 0)
	var enemy2 = enemy2_scene.instantiate()
	add_child(enemy2)
	enemy2.global_position = Vector2(-200, 100)

func _process(delta):
	timer += delta
	if timer >= check_interval:
		timer = 0.0
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var chunk = get_chunk(player.global_position)
			if chunk not in explored_chunks:
				explored_chunks[chunk] = true
				spawn_numbers_around(player.global_position, numbers_per_spawn)

func spawn_numbers_around(center: Vector2, count: int, r_min: int = 700, r_max: int = 900):
	var existing = get_tree().get_nodes_in_group("numbers")
	var attempts = 0
	var spawned = 0
	while spawned < count and attempts < 100:
		attempts += 1
		var angle = randf() * TAU
		var dist = randf_range(r_min, r_max)
		var pos = center + Vector2(cos(angle), sin(angle)) * dist
		var too_close = false
		for n in existing:
			if pos.distance_to(n.global_position) < min_distance_between:
				too_close = true
				break
		if not too_close:
			for p in used_positions:
				if pos.distance_to(p) < min_distance_between:
					too_close = true
					break
		if not too_close:
			var num = number_scene.instantiate()
			add_child(num)
			num.global_position = pos
			num.setup(randi_range(1, 9))
			spawned += 1

func register_picked_position(pos: Vector2):
	used_positions.append(pos)
