extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@export var input: PlayerInput
@export var player_id := 1:
	set(id):
		player_id = id
		input.set_multiplayer_authority(id)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var alive := true
var respawning := false

@onready var animated_sprite = $AnimatedSprite2D
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer


func _ready() -> void:
	# Set the camera for the local player node as the current one and disable the other one
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false
	
	# Must be called AFTER multiplayer_authority has been set
	# https://foxssake.github.io/netfox/latest/netfox/tutorials/responsive-player-movement/#ownership
	rollback_synchronizer.process_settings()


func _apply_animations(delta):
	var direction = input.input_direction
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")


# Applying movement here means the character will be in step with network loop ticks
func _rollback_tick(delta, tick, is_fresh):
	if not respawning:
		_apply_movement_from_input(delta)
	else:
		respawning = false
		position = MultiplayerManager.players_spawn_node.position
		velocity = Vector2.ZERO
		# Don't try to interpolate from last position because we manually changed it and want to snap to it
		$TickInterpolator.teleport()
		
		# Delay before setting alive to avoid deathloop scenarios
		await get_tree().create_timer(0.5).timeout
		alive = true


func _apply_movement_from_input(delta):
	force_update_is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	elif input.input_jump > 0:
		# Handle jump.
		velocity.y = JUMP_VELOCITY * input.input_jump
	
	# Get the input direction: -1, 0, 1
	var direction = input.input_direction
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# https://foxssake.github.io/netfox/latest/netfox/tutorials/rollback-caveats/#characterbody-velocity
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor


# Workaround to force-update the is_on_floor property after a potential position rollback
# https://foxssake.github.io/netfox/latest/netfox/tutorials/rollback-caveats/#characterbody-on-floor
func force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector2.ZERO
	move_and_slide()
	velocity = old_velocity


func _process(delta: float) -> void:
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)


func mark_dead():
	$CollisionShape2D.set_deferred("disabled", true)
	alive = false
	$RespawnTimer.start()
	print("Player %s died!" % player_id)


func _respawn():
	$CollisionShape2D.set_deferred("disabled", false)
	respawning = true
	print("Player %s respawned!" % player_id)
