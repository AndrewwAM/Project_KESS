extends Control

@onready var start_button: TextureButton = $MainContainer/Layout/Buttons/StartButton
@onready var credits_button: TextureButton = $MainContainer/Layout/Buttons/CreditsButton
@onready var exit_button: TextureButton = $MainContainer/Layout/Buttons/ExitButton

@onready var credits_panel: Control = $CreditsPanel
@onready var close_credits_button: Button = $CreditsPanel/CloseCreditsButton

@onready var click_sound: AudioStreamPlayer = $UIClickSound

const GAME_SCENE_PATH: String = "res://levels/maps/big_yard.tscn"
const TUTORIAL_SCENE_PATH: String = "res://ui/tutorial_screen.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	close_credits_button.pressed.connect(_on_close_credits_button_pressed)

	credits_panel.hide()


func _on_start_button_pressed() -> void:
	start_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	click_sound.play()
	await click_sound.finished
	if GameManager.show_tutorial:
		var error: int = get_tree().change_scene_to_file(TUTORIAL_SCENE_PATH)
		if error != OK:
			printerr("Error al cargar la escena del tutorial. Código: ", error)
	else:
		var error: int = get_tree().change_scene_to_file(GAME_SCENE_PATH)
		if error != OK:
			printerr("Error al cargar la escena del tutorial. Código: ", error)

func _on_credits_button_pressed() -> void:
	click_sound.play()
	credits_panel.show()

func _on_close_credits_button_pressed() -> void:
	click_sound.play()
	credits_panel.hide()

func _on_exit_button_pressed() -> void:
	start_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	click_sound.play()
	await click_sound.finished

	get_tree().quit()
