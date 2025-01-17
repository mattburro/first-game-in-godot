extends Area2D

@export var spawn_point: Marker2D
@export var slime_spawn_node: Node2D

var slime_scene = preload("res://scenes/slime.tscn")

@onready var slime_spawner: MultiplayerSpawner = $SlimeSpawner


func _ready() -> void:
	if slime_spawn_node:
		slime_spawner.spawn_path = slime_spawn_node.get_path()
	else:
		print("No slime spawn node!!")


func _process(delta: float) -> void:
	pass


func spawn_slime():
	var slime_to_spawn = slime_scene.instantiate()
	slime_to_spawn.global_position = spawn_point.global_position
	
	slime_spawn_node.add_child(slime_to_spawn, true)


func _on_body_entered(body):
	if not is_multiplayer_authority():
		return
	
	print("Player %s entered slime spawn area" % body.name)
	spawn_slime.call_deferred()
