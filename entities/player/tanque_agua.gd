extends Node

signal water_changed(current: float, max_water: float)
signal empty()
signal full()

@export var max_water: float = 100.0
var current_water: float = 100.0
var can_reload: bool = false

func consume(amount: float) -> void:
	if current_water <= 0: return

	current_water -= amount
	current_water = clamp(current_water, 0.0, max_water)
	emit_signal("water_changed", current_water)

	if current_water <= 0:
		emit_signal("empty")

func reload(amount: float) -> void:
	if current_water == max_water: return # si ya está lleno, no hacer nada :)

	current_water += amount # pensaba que, en vez de recargar todo de una, que tenga que llenar progresivamente el tanque
	current_water = clamp(current_water, 0.0, max_water)
	emit_signal("water_changed", current_water)

	if current_water == max_water:
		emit_signal("full")

func has_water() -> bool:
	return current_water > 0

func is_full() -> bool:
	return current_water >= max_water
