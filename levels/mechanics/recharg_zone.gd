extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("Player"):
        var tanque = body.get_node_or_null("TanqueAgua")
        if tanque:
            tanque.can_reload = true

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("Player"):
        var tanque = body.get_node_or_null("TanqueAgua")
        if tanque:
            tanque.can_reload = false
