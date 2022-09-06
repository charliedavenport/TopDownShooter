extends Node

const PORT = 8070

onready var lobby_fetch = GotmLobbyFetch.new()
onready var host_lobby_entry = get_node("Menu/HostLobbyEntry")
onready var join_lobby_screen = get_node("Menu/JoinLobbyScreen")
onready var lobby_screen = get_node("Menu/LobbyScreen")
onready var name_entry = get_node("Menu/NameEntry")
onready var host_btn = get_node("Menu/HostBtn")
onready var join_btn = get_node("Menu/JoinBtn")

var player_info : Dictionary
var lobby_name : String

var my_info : Dictionary

func _ready():
	#get_tree().connect("network_peer_connected", self, "on_player_connected")
	host_btn.connect("pressed", self, "on_menu_hostBtn_pressed")
	join_btn.connect("pressed", self, "on_menu_joinBtn_pressed")
	host_lobby_entry.hide()
	join_lobby_screen.hide()
	name_entry.hide()
	lobby_screen.hide()

func on_menu_hostBtn_pressed() -> void:
	host_btn.hide()
	join_btn.hide()
	host()

func on_menu_joinBtn_pressed() -> void:
	host_btn.hide()
	join_btn.hide()
	join()

func host() -> void:
	name_entry.show()
	var playerName = yield(name_entry, "text_entered")
	my_info["name"] = playerName
	print("my name: %s" % playerName)
	player_info[1] = my_info
	name_entry.hide()
	host_lobby_entry.show()
	lobby_name = yield(host_lobby_entry, "text_entered")
	host_lobby_entry.hide()
	Gotm.host_lobby(false)
	Gotm.lobby.hidden = false
	Gotm.lobby.name = lobby_name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT)
	get_tree().set_network_peer(peer)
#	get_tree().connect("network_peer_connected", self, "on_player_connected")
	var network_id = get_tree().get_network_unique_id()
	print("%s hosting " % network_id)
	lobby_screen.show()
	lobby_screen.set_name(lobby_name)
	lobby_screen.add_player(playerName, network_id, true)

func join() -> void:
	name_entry.show()
	var playerName = yield(name_entry, "text_entered")
	my_info["name"] = playerName
	print("my name: %s" % playerName)
	name_entry.hide()
	var lobbies : Array = yield(lobby_fetch.first(5), "completed")
	if lobbies.empty():
		print("Could not find any lobbies :(")
		return
	join_lobby_screen.set_lobbies(lobbies)
	join_lobby_screen.show()
	var lobby : GotmLobby = yield(join_lobby_screen, "lobby_selected")
	join_lobby_screen.hide()
	print("Joining lobby: %s" % lobby.name)
	var success = yield(lobby.join(), "completed")
	if not success:
		print("Could not join lobby :(")
		return
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(Gotm.lobby.host.address, PORT)
	get_tree().set_network_peer(peer)
	yield(get_tree(), "connected_to_server")
	print("connected to server")
	#rpc("register_player", my_info)
	rpc_id(1, "submit_player_info", my_info)
	lobby_screen.show()

#func on_player_connected(id) -> void: # called on server only
#	# add player info and sync across all clients
#	print("client id %s connected" % id)

remote func submit_player_info(info) -> void: # called on server, from client
	var client_id = get_tree().get_rpc_sender_id()
	player_info[client_id] = info
	rpc("update_player_info", player_info)
	rpc("set_lobby_name", lobby_name)

remotesync func set_lobby_name(name : String) -> void:
	lobby_screen.set_name(name)

remotesync func update_player_info(value : Dictionary) -> void: # called on everyone, from server
	player_info = value
	update_lobby_screen()

func update_lobby_screen() -> void:
	lobby_screen.clear_players()
	for p_id in player_info.keys():
		var is_local = (p_id == get_tree().get_network_unique_id())
		lobby_screen.add_player(player_info[p_id]["name"], p_id, is_local)
