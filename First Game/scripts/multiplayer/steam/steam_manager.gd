extends Node

var is_owned := false
var steam_app_id := 480 # Steam's test app ID
var steam_id := 0
var steam_username := ""

var lobby_id := 0
var lobby_max_players := 4


func _init():
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))


func _process(delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam():
	var init_response: Dictionary = Steam.steamInitEx()
	print("Steam initialized: %s" % init_response)
	
	if init_response["status"] > 0:
		print("Failed to init Steam! Quiting game")
		get_tree().quit()
	
	is_owned = Steam.isSubscribed()
	#steam_id = Steam.getSteamId()
	steam_username = Steam.getPersonaName()
	
	print("Steam ID: " % steam_id)
	
	if not is_owned:
		get_tree().quit()
