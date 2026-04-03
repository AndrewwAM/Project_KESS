extends CharacterBody2D

const SPEED = 150

#var chorro = preload("res://scenes/player/chorro.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
	var current_speed = SPEED

	velocity = direction * current_speed

	move_and_slide()
	pass

#func shoot() -> void:
#	var new_chorro = chorro.instantiate()
