extends Node2D

const SPEED = 60

var direction = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_ground: RayCast2D = $RayCastGround


func _ready() -> void:
	NetworkTime.on_tick.connect(_on_tick)


func _on_tick(delta, tick):
	if ray_cast_ground.is_colliding():
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		if ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false
		
		position.x += direction * SPEED * delta
	else:
		position.y += 50.0 * delta
