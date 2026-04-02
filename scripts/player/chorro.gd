extends Node2D

const growth_cooldown = 120
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grow_size()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func grow_size() -> void:
	var levels = 5.
	for level in range(levels):
		await get_tree().create_timer(0.2).timeout
		self.scale.x = 2*scale.x
