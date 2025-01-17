extends Node

var score = 0

@onready var score_label = $ScoreLabel
@onready var multiplayer_hud: Control = %MultiplayerHUD


func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."


func become_host() -> void:
	remove_single_player()
	%NetworkManager.become_host()
	multiplayer_hud.hide()
	%SteamHUD.hide()


func join_as_client() -> void:
	join_lobby()


func use_steam():
	multiplayer_hud.hide()
	%SteamHUD.show()
	SteamManager.initialize_steam()
	Steam.lobby_match_list.connect(on_lobby_match_list)
	%NetworkManager.active_network_type = %NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM


func list_steam_lobbies():
	%NetworkManager.list_lobbies()


func join_lobby(lobby_id = 0):
	remove_single_player()
	%NetworkManager.join_as_client(lobby_id)
	multiplayer_hud.hide()
	%SteamHUD.hide()


func on_lobby_match_list(lobbies: Array):
	var lobby_container: VBoxContainer = $"../SteamHUD/Panel/Lobbies/VBoxContainer"
	for lobby_child in lobby_container.get_children():
		lobby_child.queue_free()
	
	for lobby in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
		
		var lobby_button := Button.new()
		lobby_button.text = "%s | %s" % [lobby_name, str(lobby_mode)]
		lobby_button.size = Vector2(100, 30)
		lobby_button.add_theme_font_size_override("font_size", 8)
		
		var fv = FontVariation.new()
		fv.set_base_font(load("res://assets/fonts/PixelOperator8.ttf"))
		lobby_button.add_theme_font_override("font", fv)
		lobby_button.name = "lobby_%s" % lobby
		lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		lobby_button.pressed.connect(join_lobby.bind(lobby))
		
		lobby_container.add_child(lobby_button)


func remove_single_player():
	print("Removing singleplayer player")
	
	var player_to_remove = get_tree().current_scene.get_node("Player")
	player_to_remove.queue_free()
