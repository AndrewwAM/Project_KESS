extends Node2D

@export var cone_icon: Texture2D
@export var laser_icon: Texture2D
@export var changing_mode_icon: Texture2D
@onready var mode_icon_rect: TextureRect = $WaterBar/ModeIcon

@onready var health_bar: ProgressBar = $HealthBar/ProgressBar
@onready var health_label: Label = $HealthBar/HealthLabel

@onready var water_bar: ProgressBar = $WaterBar/ProgressBar
@onready var water_label: Label = $WaterBar/WaterLabel

func _ready() -> void:
	# Inicializar valores visuales con los valores actuales del GameManager
	water_bar.max_value = GameManager.water_max
	water_bar.value = GameManager.water_amount
	water_label.text = str(int(GameManager.water_amount)) + " / " + str(int(GameManager.water_max))
	$Score.text = "Score: " + str(GameManager.score)

	GameManager.score_changed.connect(_on_score_changed)

	# Conectar señales
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return


	player.get_node("TanqueAgua").water_changed.connect(_on_water_changed)
	var chorro = player.get_node("WeaponPivot").get_node("Chorro")
	chorro.mode_changed.connect(_on_mode_changed)

	_on_mode_changed(chorro.current_mode, chorro.is_switching)

	player.health_changed.connect(_on_health_changed)
	_on_health_changed(player.current_health, player.max_health)

# Se ejecuta cada vez que GameManager emite water_changed
func _on_water_changed(new_amount: float) -> void:
	water_bar.value = new_amount
	water_label.text = str(int(new_amount)) + " / " + str(int(GameManager.water_max))

# Se ejecuta cada vez que GameManager emite score_changed
func _on_score_changed(new_score: int) -> void:
	$Score.text = "Score: " + str(new_score)

# Se ejecuta cada vez que GameManager emite health_changed
func _on_health_changed(current_health: float, max_health: float) -> void:
	health_bar.value = current_health
	health_bar.max_value = max_health
	health_label.text = str(int(current_health)) + " / " + str(int(max_health))

func _on_mode_changed(new_mode: int, is_switching: bool) -> void:
	if is_switching:
		mode_icon_rect.texture = changing_mode_icon
	else:
		# 0 PressureMode.CONE, 1 PressureMode.LASER
		if new_mode == 0:
			mode_icon_rect.texture = cone_icon
		else:
			mode_icon_rect.texture = laser_icon
