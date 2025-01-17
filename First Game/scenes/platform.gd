extends AnimatableBody2D

@export var animation_player: AnimationPlayer


func _ready() -> void:
	if animation_player:
		multiplayer.peer_connected.connect(_on_player_connected)


func _on_player_connected():
	# Stop the animation player (which changes position) on clients and just sync its position from the server
	if not multiplayer.is_server():
		animation_player.stop()
		animation_player.active = false
