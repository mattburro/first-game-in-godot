class_name PlayerInput extends Node

var input_direction = Vector2.ZERO
var input_jump := 0


func _ready():
	# Framerate-independent ticks that are synced between client and server
	NetworkTime.before_tick_loop.connect(_on_before_tick_loop)
	
	# Only run this for the player instance the local client has authority of
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
	
	input_direction = Input.get_axis("move_left", "move_right")


func _on_before_tick_loop():
	if not is_multiplayer_authority():
		return
	
	input_direction = Input.get_axis("move_left", "move_right")


# Old approach without lag compensation
#func _physics_process(delta: float) -> void:
	#input_direction = Input.get_axis("move_left", "move_right")


func _process(delta: float) -> void:
	input_jump = Input.get_action_strength("jump")
