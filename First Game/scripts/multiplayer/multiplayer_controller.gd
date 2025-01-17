extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1
var do_jump := false
var _is_on_floor := true
var alive := true

@onready var animated_sprite = $AnimatedSprite2D


func _ready() -> void:
	# Set the camera for the local player node as the current one and disable the other one
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false


func _apply_animations(delta):
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if _is_on_floor:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")


func _apply_movement_from_input(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if do_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		do_jump = false

	# Get the input direction: -1, 0, 1
	direction = %InputSynchronizer.input_direction
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		# Annoying fix because we disable collision when dead
		if not alive and is_on_floor():
			_set_alive()
		
		_is_on_floor = is_on_floor()
		_apply_movement_from_input(delta)
	
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)


func mark_dead():
	alive = false
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()
	print("Player %s died!" % player_id)


func _respawn():
	global_position = get_tree().current_scene.get_node("PlayerSpawnPoint").global_position
	$CollisionShape2D.set_deferred("disabled", false)
	print("Player %s respawned!" % player_id)


func _set_alive():
	alive = true
	Engine.time_scale = 1.0
	print("Player %s alive again!" % player_id)
