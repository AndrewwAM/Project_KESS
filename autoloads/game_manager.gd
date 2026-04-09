extends Node

# Acá se trackea el estado de juego, por default será PLAYING :)))
enum GameState { PLAYING, GAME_OVER, WIN }
var state: GameState = GameState.PLAYING

# --- Oleadas ---
enum WaveState { INACTIVE, ACTIVE, RESTING }
@export var wave_duration = 30.0
@export var rest_duration = 10.0
@export var spawn_interval: float = 0.5

# Oleadas: [base, tank, speed]
@export var waves: Array = [
	[20, 0, 0],
	[25, 1, 0],
	[20, 0, 10],
	[30, 2, 15],
	[35, 5, 20],
]

var wave_state: WaveState = WaveState.INACTIVE
var current_wave_index: int = 0
var wave_timer: float = 0.0
var rest_timer: float = 0.0
var spawners: Array[Node2D] = []

var enemies_to_spawn: Array[String] = []
var total_enemies_in_wave: int = 0
var spawner_index: int = 0
var spawn_timer: Timer

# tutorial
var show_tutorial: bool = true

# Para UI
signal wave_changed(new_wave: int)
signal wave_timer_changed(time_left: float)
signal rest_started(rest_time: float)

# Variables genéricas para trackear mas leseras :)
var damage_taken: int = 0 # pal gameover, never used lol
# var score: int = 0 # pal gameover
var water_amount: float = 100.0 # Partes sin tanque lleno pq estabas regando obviamente.
var water_max: float = 100.0
var current_wave: int = 0 # pal gamover
var max_waves: int = 5 # ESTO SE EDITA DESDE ACA OJO CUIDADO
var current_kills: int = 0
var current_enemies: int = 0 # enemigos vivos actuales.
var begin: bool = false

# --- Señales ---
# Por lo que sé, estas cosas son ANUNCIOS de cambios de variables.
signal water_changed(new_amount: float)
# signal score_changed(new_score: int)
signal kill_count_changed(new_kills: int)
signal enemies_changed(new_amount: int)
signal game_over()
signal game_won()

@export_group("Referencias")
@export var player: CharacterBody2D
@export var game_over_screen: CanvasLayer

func _ready() -> void:
	await get_tree().process_frame

	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)

	GameManager.start_next_wave()

func _process(delta: float) -> void:
	if state != GameState.PLAYING:
		return

	if wave_state == WaveState.ACTIVE:
		wave_timer -= delta
		emit_signal("wave_timer_changed", wave_timer)

		var is_last_wave = current_wave_index >= waves.size() - 1
		var no_more_enemies = current_enemies <= 0 and enemies_to_spawn.is_empty()
		if ((wave_timer <= 0.0 or no_more_enemies) and not is_last_wave) or (is_last_wave and no_more_enemies):
			end_wave()

	elif wave_state == WaveState.RESTING:
		rest_timer -= delta
		emit_signal("wave_timer_changed", rest_timer)

		if rest_timer <= 0.0:
			start_next_wave()

func register_spawner(spawner: Node2D) -> void:
	if not spawners.has(spawner):
		spawners.append(spawner)

func start_next_wave() -> void:
	if current_wave_index >= waves.size():
		trigger_win()
		return

	wave_state = WaveState.ACTIVE
	wave_timer = wave_duration

	var wave_data = waves[current_wave_index]

	emit_signal("wave_changed", current_wave_index + 1)
	prepare_spawn_queue(wave_data)

func end_wave() -> void:
	wave_state = WaveState.RESTING
	rest_timer = rest_duration
	current_wave_index += 1
	spawn_timer.stop()
	enemies_to_spawn.clear()
	emit_signal("rest_started", rest_duration)

func prepare_spawn_queue(enemy_counts: Array) -> void:
	enemies_to_spawn.clear()

	var base_count = enemy_counts[0]
	var tank_count = enemy_counts[1]
	var speed_count = enemy_counts[2]

	for i in range(base_count):
		enemies_to_spawn.append("base")
	for i in range(tank_count):
		enemies_to_spawn.append("tank")
	for i in range(speed_count):
		enemies_to_spawn.append("speed")

	enemies_to_spawn.shuffle()
	total_enemies_in_wave = enemies_to_spawn.size()
	# current_enemies = 0

	if not enemies_to_spawn.is_empty():
		spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if enemies_to_spawn.is_empty() or spawners.is_empty():
		spawn_timer.stop()
		return

	var enemy_type = enemies_to_spawn.pop_back()
	var spawner = spawners[spawner_index % spawners.size()]
	spawner.spawn_specific_enemy(enemy_type)

	spawner_index += 1
	current_enemies += 1
	emit_signal("enemies_changed", current_enemies)

func enemy_killed() -> void:
	current_enemies -= 1
	emit_signal("enemies_changed", current_enemies)
	add_kill()

	if current_enemies <= 0 and enemies_to_spawn.is_empty() and wave_state == WaveState.ACTIVE:
		end_wave()

# --- Agua ---
# Acá es donde se pone divertida la cosa.
func consume_water(amount: float) -> void:
	water_amount = clamp(water_amount - amount, 0.0, water_max)
	emit_signal("water_changed", water_amount)

func refill_water(amount: float) -> void:
	water_amount = clamp(water_amount + amount, 0.0, water_max)
	emit_signal("water_changed", water_amount)

# --- Score ---
#func add_score(points: int) -> void:
	#score += points
	#emit_signal("score_changed", score)

func next_wave() -> void:
	current_wave += 1
	print("GameManager comienza nueva oleada, Oleada ",current_wave)
	emit_signal("wave_changed", current_wave)

func add_kill() -> void:
	current_kills += 1
	emit_signal("kill_count_changed", current_kills)

func _on_enemy_spawned(amount: int) -> void:
	current_enemies += amount
	print("GameManager escuchó un spawn, enemigos restantes: ", current_enemies)

func _on_enemy_kill(amount: int) -> void:
	current_enemies -= amount
	print("GameManager escuchó una kill, enemigos restantes: ", current_enemies)
	if current_enemies <= 0 and max_waves > current_wave:
		print("GameManager decide que una nueva oleada debería ocurrir.")
		next_wave()

# --- Transiciones ---
func trigger_game_over() -> void:
	state = GameState.GAME_OVER
	emit_signal("game_over")

func trigger_win() -> void:
	state = GameState.WIN
	emit_signal("game_won")

func restart() -> void:
	get_tree().reload_current_scene()

func reset_manager() -> void: # MANAGER NUKE

	if spawn_timer:
		spawn_timer.stop()
		
	spawners.clear()
	
	enemies_to_spawn.clear()
	
	state = GameState.PLAYING
	wave_state = WaveState.INACTIVE
	current_wave_index = 0
	current_wave = 0
	current_enemies = 0
	current_kills = 0
	
	wave_timer = 0.0
	rest_timer = 0.0
	
	water_amount = water_max
