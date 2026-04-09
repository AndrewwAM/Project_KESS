@tool # tambien pa actualizar en tiempo real
extends Node2D

@onready var cone_water_particles: GPUParticles2D = $ConeWaterParticles
@onready var laser_guide: Line2D = $LaserGuide
@onready var laser_line: Line2D = $LaserLine
@onready var cone_mode: Node2D = $ConeMode
@onready var laser_mode: Area2D = $LaserMode
@onready var laser_hitbox: CollisionShape2D = $LaserMode/LaserHitbox
@onready var pivot: Node2D = get_parent() as Node2D

# AUDIO, NO SUBIR O SUFRIR LAS CONSECUENCIAS
@onready var water_sound: AudioStreamPlayer = $WaterSound
@onready var weapon_swap_sound: AudioStreamPlayer = $SwapSound

@export_group("Configuración de Sonido")
@export var cone_volume_db: float = 0
@export var cone_volume_pitch: float = 1.9
@export var laser_volume_db: float = 5
@export var laser_volume_pitch: float = 2

enum PressureMode { CONE, LASER }
var current_mode: PressureMode = PressureMode.CONE
var is_shooting: bool = false
var is_switching: bool = false
var keep_shooting: bool = false
var switch_cooldown = 1.0
var cone_water_consume = 5.0
var laser_water_consume = 30.0

@export var cone_rotation_speed: float = 6.0
@export var laser_rotation_speed: float = 1.5
@export var tanque: Node
var current_rotation_speed = cone_rotation_speed

var damage_cone: float = 70.0
var damage_laser: float = 150.0

enum Modo {Cono, Laser}

# Medio webeo solo pa poder actualizar en tiempo real
@export_group("Configuración del Cono")
@export var ray_count: int = 5:
	set(value):
		ray_count = value
		actualizar_cono()

@export var ray_length: float = 150.0:
	set(value):
		ray_length = value
		actualizar_cono()

@export var cone_angle_degrees: float = 45.0:
	set(value):
		cone_angle_degrees = value
		actualizar_cono()

@export var cone_particle_speed: float = 300.0:
	set(value):
		cone_particle_speed = value
		actualizar_cono()

@export var cone_particle_lifetime_ratio: float = 1.0:
	set(value):
		cone_particle_lifetime_ratio = value
		actualizar_cono()

# Un par más para el laser
@export_group("Configuración del Láser")
@export var laser_length: float = 300.0:
	set(value):
		laser_length = value
		actualizar_laser()

@export var laser_particle_amount: int = 100:
	set(value):
		laser_particle_amount = value
		actualizar_laser()

@export var laser_particle_speed: float = 600.0:
	set(value):
		laser_particle_speed = value
		actualizar_laser()

@export var laser_particle_lifetime_ratio: float = 1.0:
	set(value):
		laser_particle_lifetime_ratio = value
		actualizar_laser()

@export var laser_knockback_force: float = 1500.0

var player: Node2D = null
signal mode_changed(new_mode: int, is_switching: bool)

func _ready() -> void:
	if Engine.is_editor_hint():
		actualizar_cono()
		return

	player = get_tree().get_first_node_in_group("Player")
	laser_guide.visible = false
	laser_line.visible = false
	cone_water_particles.emitting = false
	water_sound.volume_db = cone_volume_db
	water_sound.pitch_scale = cone_volume_pitch
	stop_shooting()
	actualizar_cono()


func actualizar_cono() -> void:
	if not is_node_ready() or cone_mode == null or player == null:
		return

	for child in cone_mode.get_children():
		if child is RayCast2D:
			child.free()

	var angle_rad = deg_to_rad(cone_angle_degrees)
	var start_angle = -angle_rad / 2.0
	var angle_step = angle_rad / (ray_count - 1) if ray_count > 1 else 0.0

	for i in range(ray_count):
		var ray = RayCast2D.new()
		ray.target_position = Vector2.RIGHT * ray_length
		ray.rotation = start_angle + (angle_step * i)
		ray.enabled = false
		ray.set_collision_mask_value(3, true)
		cone_mode.add_child(ray)
		
		# Puntos guia
		var punto_guia = ColorRect.new()
		punto_guia.size = Vector2(4.0, 4.0)
		punto_guia.color = Color(0.6, 0.9, 1.0, 0.4)
		
		punto_guia.position = ray.target_position - (punto_guia.size / 2.0)
		ray.add_child(punto_guia)

	var cone_material = cone_water_particles.process_material as ParticleProcessMaterial
	if cone_material:
		cone_material.spread = cone_angle_degrees / 2.0
		cone_material.initial_velocity_min = cone_particle_speed
		cone_material.initial_velocity_max = cone_particle_speed

		cone_water_particles.lifetime = (ray_length / cone_particle_speed) * cone_particle_lifetime_ratio

func actualizar_laser() -> void:
	if not is_node_ready() or laser_hitbox == null or laser_line == null or player == null:
		print("No se puede actualizar el laser")
		return
	var shape = laser_hitbox.shape as RectangleShape2D
	if shape:
		shape.size.x = laser_length
		shape.size.y = 10.0
		laser_mode.set_collision_mask_value(3, true)

		laser_hitbox.position.x = laser_length / 2.0

	if laser_line:
			laser_line.clear_points()
			laser_line.add_point(Vector2.ZERO)
			laser_line.add_point(Vector2.RIGHT * laser_length)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	# Cambiar modo con clic derecho
	if event.is_action_pressed("shoot_alt") and !is_switching:
		if player and player.get("is_reloading"):
			return
		is_switching = true
		laser_guide.visible = false
		cone_mode.visible = false
		mode_changed.emit(current_mode, is_switching)
		pause_shooting()

		await get_tree().create_timer(switch_cooldown).timeout

		is_switching = false
		toggle_mode()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	handle_rotation(delta)

	if is_shooting:
		apply_water_damage(delta)
		apply_knockback(delta)

func handle_rotation(delta: float) -> void:
	if not pivot:
		return

	var mouse_pos: Vector2 = get_global_mouse_position()
	var target_angle: float = pivot.global_position.angle_to_point(mouse_pos)

	# Interpolar ??!!!
	pivot.rotation = lerp_angle(pivot.rotation, target_angle, current_rotation_speed * delta)

func toggle_mode() -> void:
	if current_mode == PressureMode.CONE:
		current_mode = PressureMode.LASER
		
		laser_guide.visible=true
		cone_mode.visible=false
		water_sound.volume_db = laser_volume_db
		water_sound.pitch_scale = laser_volume_pitch
	else:
		laser_guide.visible = false
		cone_mode.visible = true
		current_mode = PressureMode.CONE
		water_sound.volume_db = cone_volume_db
		water_sound.pitch_scale = cone_volume_pitch

	mode_changed.emit(current_mode, is_switching)


func start_shooting() -> void:
	keep_shooting = true
	if is_switching or is_shooting:
		return

	is_shooting = true
	if not water_sound.playing:
		# Check pro-timpanos
		water_sound.volume_db = cone_volume_db if current_mode == PressureMode.CONE else laser_volume_db
		water_sound.play()
		
	if current_mode == PressureMode.CONE:
		cone_water_particles.restart()
		set_cone_enabled(true)
		laser_hitbox.set_deferred("disabled", true)
	elif current_mode == PressureMode.LASER:
		current_rotation_speed = laser_rotation_speed
		laser_line.visible = true
		set_cone_enabled(false)
		laser_hitbox.set_deferred("disabled", false)

func stop_shooting() -> void:
	water_sound.stop()
	current_rotation_speed = cone_rotation_speed
	is_shooting = false
	keep_shooting = false
	laser_line.visible = false
	cone_water_particles.emitting = false
	set_cone_enabled(false)
	laser_hitbox.set_deferred("disabled", true)

func pause_shooting() -> void:
	is_shooting = false
	water_sound.stop()
	current_rotation_speed = cone_rotation_speed
	laser_line.visible = false
	cone_water_particles.emitting = false
	set_cone_enabled(false)
	laser_hitbox.set_deferred("disabled", true)

	while is_switching:
		await get_tree().create_timer(0.1).timeout

	if !keep_shooting:
		return
	print("Resuming")
	start_shooting()


func set_cone_enabled(enabled: bool) -> void:
	for ray in cone_mode.get_children():
		if ray is RayCast2D:
			ray.enabled = enabled


func apply_water_damage(delta: float) -> void:
	if tanque and tanque.has_water():
		var current_damage = 0.0
		var consumo = 0.0

		if current_mode == PressureMode.CONE:
			current_damage = damage_cone * delta
			consumo = cone_water_consume * delta

			var hit_this_frame: Array = []
			for ray in cone_mode.get_children():
				if ray is RayCast2D and ray.is_colliding():
					var collider = ray.get_collider()
					if collider and collider.has_method("mojar") and not hit_this_frame.has(collider):
						collider.mojar(current_damage, "cone")
						hit_this_frame.append(collider)

		elif current_mode == PressureMode.LASER:
			current_damage = damage_laser * delta
			consumo = laser_water_consume * delta

			var bodies = laser_mode.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("mojar"):
					body.mojar(current_damage, "laser")

		tanque.consume(consumo)

	else:
		stop_shooting()

func apply_knockback(delta: float) -> void:
	if current_mode != PressureMode.LASER:
		return

	var knockback_dir = Vector2.LEFT.rotated(pivot.global_rotation)
	player.knockback_velocity += knockback_dir * laser_knockback_force * delta
