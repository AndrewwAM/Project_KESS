extends Control

@onready var start_button: TextureButton = $MainContainer/Layout/ButtonLayout/StartButton
@onready var next_button: TextureButton = $MainContainer/Layout/ButtonLayout/NextButton
@onready var back_button: TextureButton = $MainContainer/Layout/ButtonLayout/BackButton
@onready var enabled_button: TextureButton = $MainContainer/Layout/Checkbox/Enabled
@onready var disabled_button: TextureButton = $MainContainer/Layout/Checkbox/Disabled

@onready var context_label: Label = $MainContainer/Layout/Context
@onready var controls_label: Label = $MainContainer/Layout/Controls
@onready var enemy_label: Label = $MainContainer/Layout/EnemyLabeling
@onready var preparation_label: Label = $MainContainer/Layout/Preparation


@onready var click_sound: AudioStreamPlayer = $UIClickSound

var current_page: int = 0
const GAME_SCENE_PATH: String = "res://levels/maps/big_yard.tscn"

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	back_button.pressed.connect(_on_back_pressed)
	start_button.pressed.connect(_on_start_pressed)
	enabled_button.pressed.connect(_on_enabled_pressed)
	disabled_button.pressed.connect(_on_disabled_pressed)
	show_page(0)
	
	
func _on_next_pressed() -> void:
	click_sound.play()
	
	current_page += 1
	show_page(current_page)
	
	
func _on_back_pressed() -> void:
	click_sound.play()
	
	current_page -= 1
	show_page(current_page)
	
func _on_start_pressed() -> void:
	start_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	click_sound.play()
	
	var error: int = get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if error != OK:
		printerr("Error al cargar la escena de juego. Código: ", error)

func _on_enabled_pressed() -> void:
	# pasa del verde al rojo, Mostrar tutorial a falso
	click_sound.play()
		
	GameManager.show_tutorial = false
	enabled_button.visible = false
	disabled_button.visible = true

func _on_disabled_pressed() -> void:
	# pasa del rojo al verde, Mostrar tutorial a true
	click_sound.play()
	
	GameManager.show_tutorial = true
	disabled_button.visible = false
	enabled_button.visible = true

func show_page(page: int) -> void:
	context_label.visible = page == 0
	controls_label.visible = page == 1
	enemy_label.visible = page == 2
	preparation_label.visible = page == 3
	
	next_button.visible = page != 3 # boton next visible hasta la última página
	back_button.visible = page != 0 # boton back visible desde la segunda página
	start_button.visible = page == 3 #boton start solo visible en la última página
	
	
