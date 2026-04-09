extends CanvasLayer

@onready var resume_button = $ColorRect/VBoxContainer/ResumeButton
@onready var main_menu_button = $ColorRect/VBoxContainer/MainMenuButton

const MAIN_MENU_SCENE_PATH: String = "res://ui/main_menu.tscn"

@onready var click_sound: AudioStreamPlayer = $UIClickSound

func _ready() -> void:
	hide()
	resume_button.pressed.connect(_on_resume_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

func _on_resume_button_pressed() -> void:
	click_sound.play()
	toggle_pause()

func _on_main_menu_button_pressed() -> void:
	click_sound.play()
	await click_sound.finished
	GameManager.reset_manager()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
