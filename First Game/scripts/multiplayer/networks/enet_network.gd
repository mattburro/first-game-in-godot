extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_player_scene = preload("res://scenes/multiplayer_player.tscn")
var multiplayer_peer := ENetMultiplayerPeer.new()
var players_spawn_node: Node2D


func become_host():
	print("Starting as host!")
	
	multiplayer_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.peer_connected.connect(add_player_to_game)
	multiplayer.peer_disconnected.connect(delete_player)
	
	# Add yourself (the host) to the game manually since the above peer_connected callback doesn't trigger for you. Host's id is always 1.
	add_player_to_game(1)


func join_as_client(lobby_id):
	print("Player joining")
	
	multiplayer_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer


func add_player_to_game(id: int):
	print("Player %s joined the game" % id)
	
	var player_to_add = multiplayer_player_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	players_spawn_node.add_child(player_to_add, true)


func delete_player(id: int):
	print("Player %s left the game" % id)
	
	if not players_spawn_node.has_node(str(id)):
		return
	
	players_spawn_node.get_node(str(id)).queue_free()
