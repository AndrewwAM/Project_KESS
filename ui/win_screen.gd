extends CanvasLayer

@onready var main_menu_button = $ColorRect/VBoxContainer/MainMenuButton

const MAIN_MENU_SCENE_PATH: String = "res://ui/main_menu.tscn"

@onready var click_sound: AudioStreamPlayer = $UIClickSound

func _ready() -> void:
	hide()
	GameManager.game_won.connect(_on_game_won)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _on_main_menu_button_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _on_game_won() -> void:
	show()
	get_tree().paused = true
