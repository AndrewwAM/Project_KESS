extends Node2D

const ENEMY_SCENES = {
	"base": preload("res://entities/enemies/base_enemy.tscn"),
	"speed": preload("res://entities/enemies/speed_enemy.tscn"),
	"tank": preload("res://entities/enemies/tank_enemy.tscn")
}

@export var radius: float = 30.0
var current_scene: Node = null

func _ready() -> void:
	current_scene = get_tree().current_scene
	GameManager.register_spawner(self)

func spawn_specific_enemy(enemy_type: String) -> void:
	if not ENEMY_SCENES.has(enemy_type):
		return

	#print("Spawning enemy of type: " + enemy_type)
	var enemy = ENEMY_SCENES[enemy_type].instantiate()

	var parent_node = get_parent()
	parent_node.call_deferred("add_child", enemy)

	var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
	var final_position = global_position + random_offset
	enemy.set_deferred("global_position", final_position)

	enemy.tree_exited.connect(_on_enemy_defeated)

func _on_enemy_defeated() -> void: # no pongo killed o died pq no mueren, son apaciguados :)))
	GameManager.enemy_killed()
