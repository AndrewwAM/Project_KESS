extends Node2D

@onready var cone_water_particles: GPUParticles2D = $ConeWaterParticles
@onready var laser_water_particles: GPUParticles2D = $LaserWaterParticles
@onready var cone_mode: Node2D = $ConeMode
@onready var laser_mode: Area2D = $LaserMode
@onready var laser_hitbox: CollisionShape2D = $LaserMode/LaserHitbox
@onready var pivot: Node2D = get_parent()


enum PressureMode { CONE, LASER }
var current_mode: PressureMode = PressureMode.CONE
var is_shooting: bool = false
var is_switching: bool = false
var switch_cooldown = 1.0

@export var cone_rotation_speed: float = 6.0
@export var laser_rotation_speed: float = 6.0
var current_rotation_speed = cone_rotation_speed

var damage_cone: float = 20.0
var damage_laser: float = 50.0

enum Modo {Cono, Laser}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	laser_water_particles.emitting = false
	stop_shooting()
	#pass

func _unhandled_input(event: InputEvent) -> void:
	# Cambiar modo con clic derecho
	if event.is_action_pressed("shoot_alt") and !is_switching:
		print("switching")
		is_switching = true
		pause_shooting()
		await get_tree().create_timer(switch_cooldown).timeout
		print("switched")
		is_switching=false
		toggle_mode()
	
	# Disparar con clic izquierdo (mantener)
	if event.is_action_pressed("shoot_main"):
		print("trying to shoot!")
		start_shooting()
	elif event.is_action_released("shoot_main"):
		stop_shooting()
		
func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	
	if is_shooting:
		apply_water_damage(delta)

func handle_rotation(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var target_angle: float = pivot.global_position.angle_to_point(mouse_pos)
	
	# Interpolar ??!!!
	pivot.rotation = lerp_angle(pivot.rotation, target_angle, current_rotation_speed * delta)

func toggle_mode() -> void:
	if current_mode == PressureMode.CONE:
		current_rotation_speed = laser_rotation_speed
		current_mode = PressureMode.LASER
		# (Opcional) Cambiar a un azul más oscuro para dar feedback visual
		#cone_water_particles.process_material.color = Color(0.2, 0.4, 1.0) 
	else:
		current_mode = PressureMode.CONE
		current_rotation_speed = cone_rotation_speed
		# Volver al azul claro
		#cone_water_particles.process_material.color = Color(0.6, 0.9, 1.0) 
	

func start_shooting() -> void:
	is_shooting = true
	if is_switching:
		return

	if current_mode == PressureMode.CONE:
		cone_water_particles.emitting = true
		set_cone_enabled(true)
		laser_hitbox.set_deferred("disabled", true) 
	elif current_mode == PressureMode.LASER:
		laser_water_particles.emitting = true
		set_cone_enabled(false)
		laser_hitbox.set_deferred("disabled", false)

func stop_shooting() -> void:
	is_shooting = false
	#if current_mode == PressureMode.CONE:
	#	cone_water_particles.emitting = false
	#else:
	#	laser_water_particles.emitting = false

	# Se apaga tanto partículas como hitboxes
	laser_water_particles.emitting = false
	cone_water_particles.emitting = false
	set_cone_enabled(false)
	laser_hitbox.set_deferred("disabled", true)

func pause_shooting() -> void:
	is_shooting = false

	laser_water_particles.emitting = false
	cone_water_particles.emitting = false
	set_cone_enabled(false)
	laser_hitbox.set_deferred("disabled", true)

	while is_switching:
		await get_tree().create_timer(0.1).timeout
	
	print("Resuming")
	start_shooting()

	
func set_cone_enabled(enabled: bool) -> void:
	for ray in cone_mode.get_children():
		if ray is RayCast2D:
			ray.enabled = enabled
			
func apply_water_damage(delta: float) -> void:
	if current_mode == PressureMode.CONE:
		var current_damage = damage_cone * delta
		for ray in cone_mode.get_children():
			if ray is RayCast2D and ray.is_colliding():
				var collider = ray.get_collider()
				if collider and collider.has_method("mojar"):
					collider.mojar(current_damage)
					
	elif current_mode == PressureMode.LASER:
		var current_damage = damage_laser * delta
		# get_overlapping_bodies obtiene TODOS los enemigos atravesados por el laser
		var bodies = laser_mode.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("mojar"):
				body.mojar(current_damage)
