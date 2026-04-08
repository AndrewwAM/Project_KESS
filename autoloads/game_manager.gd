extends Node

# Acá se trackea el estado de juego, por default será PLAYING :)))
enum GameState { PLAYING, GAME_OVER, WIN }
var state: GameState = GameState.PLAYING

# Variables genéricas para trackear mas leseras :)
var damage_taken: int = 0 # pal gameover
var health: int = 5
var max_health: int = 5
var score: int = 0 # pal gameover
var water_amount: float = 100.0 # Partes sin tanque lleno pq estabas regando obviamente.
var water_max: float = 100.0
var current_wave: int = 0 # pal gamover
var max_waves: int = 5 # ESTO SE EDITA DESDE ACA OJO CUIDADO
var current_kills: int = 0
var current_enemies: int = 0 # enemigos vivos actuales.
var begin: bool = false

# --- Señales ---
# Por lo que sé, estas cosas son ANUNCIOS de cambios de variables.
signal health_changed(new_health: int)
signal water_changed(new_amount: float)
signal score_changed(new_score: int)
signal wave_changed(new_wave: int)
# signal damage_changed(new_damage: int)
signal kill_count_changed(new_kills: int)
signal game_over()
signal game_won()




# --- Agua ---
# Acá es donde se pone divertida la cosa.
func consume_water(amount: float) -> void:
	water_amount = clamp(water_amount - amount, 0.0, water_max)
	emit_signal("water_changed", water_amount)

func refill_water(amount: float) -> void:
	water_amount = clamp(water_amount + amount, 0.0, water_max)
	emit_signal("water_changed", water_amount)

# --- Score ---
func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)

# --- Daño ---
func take_damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	emit_signal("health_changed", health)
	damage_taken += 1
	#if health <= 0:
		#trigger_game_over()

func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	emit_signal("health_changed", health)


# --- Oleadas ---
func _ready() -> void:
	if current_enemies <= 0:
		next_wave()
		
		

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
	if current_enemies <= 0 && max_waves > current_wave:
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
	
