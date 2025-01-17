extends Node

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }

@export var players_spawn_node: Node2D

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var enet_network_scene := preload("res://scenes/multiplayer/networks/enet_network.tscn")
var steam_network_scene := preload("res://scenes/multiplayer/networks/steam_network.tscn")
var active_network


func build_multiplayer_network():
	if not active_network:
		print("Setting active_network")
		
		MultiplayerManager.multiplayer_mode_enabled = true
		
		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				set_active_network(enet_network_scene)
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				set_active_network(steam_network_scene)
			_:
				print("No matching network type!")


func set_active_network(active_network_scene):
	# Gotta add the network scene for certain functionality
	var network = active_network_scene.instantiate()
	active_network = network
	active_network.players_spawn_node = players_spawn_node
	MultiplayerManager.players_spawn_node = players_spawn_node
	add_child(active_network)


func become_host():
	build_multiplayer_network()
	MultiplayerManager.host_mode_enabled = true
	active_network.become_host()


func join_as_client(lobby_id = 0):
	build_multiplayer_network()
	active_network.join_as_client(lobby_id)


func list_lobbies():
	build_multiplayer_network()
	active_network.list_lobbies()
