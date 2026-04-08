extends CharacterBody2D

@export var max_health: float = 100.0
@export var speed: float = 150.0
@onready var camera: Camera2D = $Camera2D

@export_group("Configuración de Cámara")
@export var camera_max_distance: float = 150.0
@export var camera_mouse_influence: float = 0.4
@export var camera_deadzone: float = 40.0 # El radio donde la cámara no se mueve
@export var camera_smooth_speed: float = 8.0 # Qué tan rápido se suaviza el offset

@export_group("Physics")
@export var knockback_force: float = 10.0
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var Animator: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: String = "down"
var is_shooting: bool = false
var current_health: float = max_health

signal health_changed(current_health: float, max_health: float)

func _process(_delta: float) -> void:
	is_shooting = Input.is_action_pressed("shoot_main")

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_force * delta)
	velocity = (direction * speed) + knockback_velocity
	move_and_slide()

	actualizar_camara(delta)

	var aim_direction = get_local_mouse_position().normalized()
	update_animation(direction, aim_direction)

func actualizar_camara(delta: float) -> void:
	var mouse_local_pos: Vector2 = get_local_mouse_position()
	var distance_to_mouse: float = mouse_local_pos.length()

	var target_offset: Vector2 = Vector2.ZERO

	if distance_to_mouse > camera_deadzone:
		var limited_pos = mouse_local_pos.limit_length(camera_max_distance)

		target_offset = limited_pos * camera_mouse_influence

	camera.offset = camera.offset.lerp(target_offset, camera_smooth_speed * delta)


func update_animation(move_dir: Vector2, aim_dir: Vector2) -> void:
	var animation_direction: String = last_direction

	if is_shooting:
		animation_direction = get_cardinal_direction(aim_dir)
		last_direction = animation_direction
	elif move_dir != Vector2.ZERO:
		animation_direction = get_cardinal_direction(move_dir)
		last_direction = animation_direction

	if move_dir == Vector2.ZERO:
		Animator.play("idle_" + animation_direction)
	else:
		Animator.play("player_move_" + animation_direction)

func get_cardinal_direction(direction: Vector2) -> String:
	var angle := direction.angle()

	if angle >= -PI/4 and angle <= PI/4:
		return "right"
	elif angle > PI/4 and angle < 3*PI/4:
		return "down"
	elif angle <= -PI/4 and angle > -3*PI/4:
		return "up"
	else:
		return "left"

func take_damage(amount: float) -> void:
	current_health -= amount

	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0:
		GameManager.trigger_game_over()
		hide()
		set_physics_process(false)
		set_process(false)
