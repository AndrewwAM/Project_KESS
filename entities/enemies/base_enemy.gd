extends CharacterBody2D

@export var life: float = 100.0
@export var speed: float = 50.0
@export var wobble_angle: float = 15.0
@export var wobble_speed: float = 0.15

@onready var sprite: Sprite2D = $Sprite2D

var player: Node2D = null
var time_passed: float = 0.0

func _ready() -> void:
    player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta: float) -> void:
    if player == null:
        return

    var direction: Vector2 = global_position.direction_to(player.global_position)
    velocity = direction * speed

    move_and_slide()

func _process(delta: float) -> void:
    var current_speed: float = get_real_velocity().length()

    if current_speed > 1.0:
        time_passed += delta * current_speed * wobble_speed
        sprite.rotation_degrees = sin(time_passed) * wobble_angle
    else:
        sprite.rotation_degrees = lerp(sprite.rotation_degrees, 0.0, delta * 10.0)
        time_passed = 0.0

    if life <= 0:
        queue_free()

func mojar(damage: float) -> void:
    #print("Enemy hit! Damage: ", damage)
    life -= damage
