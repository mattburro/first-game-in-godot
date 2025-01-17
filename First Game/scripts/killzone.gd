extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if not MultiplayerManager.multiplayer_mode_enabled:
		print("You died!")
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	else:
		print("Player %s entered kill zone" % body.player_id)
		_multiplayer_dead(body)


func _multiplayer_dead(body):
	if multiplayer.is_server() and body.alive:
		body.mark_dead()


func _on_timer_timeout():
	get_tree().reload_current_scene()
