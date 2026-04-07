extends CharacterBody2D

@export var life: float = 100.0
@export var speed: float = 150.0
@onready var camera: Camera2D = $Camera2D

@export_group("Configuración de Cámara")
@export var camera_max_distance: float = 150.0 
@export var camera_mouse_influence: float = 0.4 
@export var camera_deadzone: float = 40.0 # El radio donde la cámara no se mueve
@export var camera_smooth_speed: float = 8.0 # Qué tan rápido se suaviza el offset

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	var current_speed = speed

	velocity = direction * current_speed

	move_and_slide()
	
func _physics_process(delta: float) -> void:
	actualizar_camara(delta)

func actualizar_camara(delta: float) -> void:
	var mouse_local_pos: Vector2 = get_local_mouse_position()
	var distance_to_mouse: float = mouse_local_pos.length()
	
	var target_offset: Vector2 = Vector2.ZERO
	
	if distance_to_mouse > camera_deadzone:
		var limited_pos = mouse_local_pos.limit_length(camera_max_distance)
		
		target_offset = limited_pos * camera_mouse_influence
	
	camera.offset = camera.offset.lerp(target_offset, camera_smooth_speed * delta)
