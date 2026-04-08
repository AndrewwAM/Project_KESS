extends Area2D

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
