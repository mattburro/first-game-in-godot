extends Node

const LOBBY_NAME = "PYROS AMAZING GAME"
const LOBBY_MODE = "CoOP" # Co-op

var multiplayer_player_scene = preload("res://scenes/multiplayer_player.tscn")
var multiplayer_peer := SteamMultiplayerPeer.new()
var players_spawn_node: Node2D
var hosted_lobby_id

func _ready() -> void:
	#multiplayer_peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_created.connect(_on_lobby_created.bind())


func become_host():
	print("Starting as host!")
	
	multiplayer.peer_connected.connect(add_player_to_game)
	multiplayer.peer_disconnected.connect(delete_player)
	
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, SteamManager.lobby_max_players)


func join_as_client(lobby_id):
	print("Joining lobby")
	
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.joinLobby(int(lobby_id))


func _on_lobby_created(connect: int, lobby_id):
	if connect != 1:
		return
	
	hosted_lobby_id = lobby_id
	print("Created lobby: %s" % hosted_lobby_id)
	
	Steam.setLobbyJoinable(hosted_lobby_id, true)
	Steam.setLobbyData(hosted_lobby_id, "name", LOBBY_NAME)
	Steam.setLobbyData(hosted_lobby_id, "mode", LOBBY_MODE)
	
	create_host()


func create_host():
	var error = multiplayer_peer.create_host(0)
	if error == OK:
		multiplayer.set_multiplayer_peer(multiplayer_peer)
		
		add_player_to_game(1)
	else:
		print("Error creating host: %s" % str(error))


func _on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	# Response code 1 is a good join
	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != Steam.getSteamID():
			connect_socket(id)
	else:
		print("Error connecting to lobby")


func connect_socket(steam_id: int):
	var error = multiplayer_peer.create_client(steam_id, 0)
	if error == OK:
		multiplayer.set_multiplayer_peer(multiplayer_peer)
	else:
		print("Error creating client: %s" % str(error))


func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_DEFAULT)
	Steam.addRequestLobbyListStringFilter("name", LOBBY_NAME, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


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
