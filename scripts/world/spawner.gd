extends Node2D

const ENEMY_SCENES = {
	"base": preload("res://entities/enemies/base_enemy.tscn"),
	"speed": preload("res://entities/enemies/speed_enemy.tscn"),
	"tank": preload("res://entities/enemies/tank_enemy.tscn")
}

@export var enemies_per_wave: int = 3 #editable obvio, igual podríá aumentar o disminuir por oleada.
@export var spawn_points: Array[Vector2] = [] # Para que puedan tener más de un solo spawn.
@export var max_waves: int = 5 # also editable
@export var valid_waves: Array[int] = [] # Esto es para que solo selectas oleadas hagan spawnear enemigos.
 # Tipo, si valid_waves es [1,2,5], solo spawnearán enemigos en las oleadas 1, 2 y 5 (para este spawner).
# Probado, funciona pero hay que probar qué ocurre con múltiples spawners.
# su inicio de variables en valores default. 
var enemy_types: Array[String] = ["base", "speed", "tank"]
@export var type: int = 0 # 0 es base, 1 es speed y 2 es tank.


var enemies_alive: int = 0
var current_wave: int = 0

func _ready() -> void:
	
	#print("spawner ready")
	spawn_wave()
	
func spawn_wave() -> void:
	# Primero, la oleada que spawnea será la primera, luego la segunda y así.
	var enemy_type: String = enemy_types[type] # desperate try?
	current_wave += 1 # se hace así para que puedan haber infinitas oleadas.
	if current_wave not in valid_waves: #se valida si la oleada actual NO está en la lista de oleadas válidas.
		return # si no lo está, se sube el counter y luego se retorna sin hacer nada más.
	
	print("se va a spawnear el enemigo tipo: ", enemy_type)
	enemies_alive += enemies_per_wave # en vez de igualar, se suma, ya que de esta forma se pueden spawnear enemigos antes de que todos sean derrotados
	GameManager.next_wave() #info pal game manager.
	print("Oleada ", current_wave, " comenzada")
	# ahora se spawnean los enemigos
	for i in range(enemies_per_wave):
		var enemy = ENEMY_SCENES[enemy_type].instantiate() #instanciar y posición de spawn
		var spawn_position = spawn_points[i % spawn_points.size()]
		enemy.global_position = spawn_position
		#print("Enemigo instanciado y posición decidida: ", enemy.global_position)
		
		enemy.tree_exited.connect(_on_enemy_defeated) #escuchar para cuando sea derrotado
		get_tree().current_scene.call_deferred("add_child", enemy)
		#print("enemigo spawneado")

		
func _on_enemy_defeated() -> void: # no pongo killed o died pq no mueren, son apaciguados :)))
	#print("enemigo derrotado!")
	enemies_alive -= 1
	GameManager.add_kill()
	if enemies_alive <= 0 && !(current_wave >= max_waves): # si todos fueron derrotados Y aún no pasa la última oleada.
		spawn_wave()
