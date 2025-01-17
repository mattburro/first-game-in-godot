extends MultiplayerSynchronizer

var input_direction: float

@onready var player: CharacterBody2D = $".."


func _ready():
	# Only run this on local client
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
	
	input_direction = Input.get_axis("move_left", "move_right")


func _physics_process(delta: float) -> void:
	input_direction = Input.get_axis("move_left", "move_right")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump.rpc()


@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true
