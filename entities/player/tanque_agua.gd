extends Node

signal water_changed(current: float, max_water: float)
signal empty()

@export var max_water: float = 100.0
var current_water: float = 100.0

func consume(amount: float) -> void:
	if current_water <= 0: return
	
	current_water -= amount
	current_water = clamp(current_water, 0.0, max_water)
	emit_signal("water_changed", current_water, max_water)
	
	print("Agua actual:", current_water)

	if current_water <= 0:
		emit_signal("empty")

func has_water() -> bool:
	return current_water > 0
