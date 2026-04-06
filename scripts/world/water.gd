extends Area2D

func _ready() -> void:
	# hacer conexiones
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.get_node("TanqueAgua").can_reload = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.get_node("TanqueAgua").can_reload = false
