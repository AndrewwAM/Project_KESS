extends CharacterBody2D

@export var life: float = 100.0
@export var speed: float = 50.0
@export var path_update_interval: float = 0.2
var path_update_timer: float = 0.0

@export_group("Wobble")
@export var wobble_angle: float = 15.0
@export var wobble_speed: float = 0.15

@export_group("Immunities")
@export var immune_to_cone: bool = false
@export var immune_to_laser: bool = false



@onready var sprite: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var player: Node2D = null
var time_passed: float = 0.0
var hit_tween: Tween

signal enemy_defeated

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

	# configuración pathfinding
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0

func _physics_process(_delta: float) -> void:
	if player == null:
		return

	# mejor pathfinding
	path_update_timer += _delta
	if path_update_timer >= path_update_interval:
		nav_agent.target_position = player.global_position
		path_update_timer = 0.0

	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	# movimiento a player
	var direction: Vector2 = global_position.direction_to(next_path_position)
	velocity = direction * speed

	move_and_slide()

func _process(delta: float) -> void:
	var current_speed: float = get_real_velocity().length()

	if current_speed > 1.0:
		time_passed += delta * current_speed * wobble_speed
		sprite.rotation_degrees = sin(time_passed) * wobble_angle
	else:
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, 0.0, delta * 10.0)
		time_passed = 0.0

	if life <= 0:
		emit_signal("enemy_defeated") # Para contador de enemigos derrotados y para generar oleadas nuevas.
		queue_free()

func mojar(damage: float, weapon_type: String) -> void:
	if weapon_type == "cone" and immune_to_cone:
		return
	elif weapon_type == "laser" and immune_to_laser:
		return

	life -= damage
	_flash_damage()

func _flash_damage() -> void:
	if hit_tween and hit_tween.is_valid():
		hit_tween.kill()

	hit_tween = create_tween()
	sprite.modulate = Color(0.8, 0.1, 0.1, 1.0)
	hit_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
