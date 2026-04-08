extends Node2D

@export var cone_icon: Texture2D
@export var laser_icon: Texture2D
@export var changing_mode_icon: Texture2D

@onready var mode_icon_rect: TextureRect = $WaterBar/ModeIcon

# Cuántos corazones tiene el jugador como máximo
const MAX_HEALTH = 5

func _ready() -> void:
	# Inicializar valores visuales con los valores actuales del GameManager
	$WaterBar/ProgressBar.max_value = GameManager.water_max
	$WaterBar/ProgressBar.value = GameManager.water_amount
	$Score.text = "Score: " + str(GameManager.score)

	GameManager.score_changed.connect(_on_score_changed)
	GameManager.health_changed.connect(_on_health_changed)

	# Conectar señales
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return


	player.get_node("TanqueAgua").water_changed.connect(_on_water_changed)
	var chorro = player.get_node("WeaponPivot").get_node("Chorro")
	chorro.mode_changed.connect(_on_mode_changed)

	_on_mode_changed(chorro.current_mode, chorro.is_switching)


# Se ejecuta cada vez que GameManager emite water_changed
func _on_water_changed(new_amount: float) -> void:
	$WaterBar/ProgressBar.value = new_amount

# Se ejecuta cada vez que GameManager emite score_changed
func _on_score_changed(new_score: int) -> void:
	$Score.text = "Score: " + str(new_score)

# Se ejecuta cada vez que GameManager emite health_changed
func _on_health_changed(new_health: int) -> void:
	# Recorre los 5 corazones y muestra u oculta según la vida actual
	for i in range(MAX_HEALTH):
		# get_child(i) obtiene el hijo número i del HBoxContainer
		var heart = $Health.get_child(i)
		heart.visible = i < new_health

func _on_mode_changed(new_mode: int, is_switching: bool) -> void:
	if is_switching:
		mode_icon_rect.texture = changing_mode_icon
	else:
		# 0 PressureMode.CONE, 1 PressureMode.LASER
		if new_mode == 0:
			mode_icon_rect.texture = cone_icon
		else:
			mode_icon_rect.texture = laser_icon
