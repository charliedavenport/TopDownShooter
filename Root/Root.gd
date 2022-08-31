extends Node

const PORT = 8070

onready var lobby_fetch = GotmLobbyFetch.new()
onready var game = get_node("Game")
onready var host_lobby_entry = get_node("Menu/HostLobbyEntry")
onready var join_lobby_list = get_node("Menu/JoinLobbyList")
onready var name_entry = get_node("Menu/NameEntry")
onready var host_btn = get_node("Menu/HostBtn")
onready var join_btn = get_node("Menu/JoinBtn")

var player_info : Dictionary

var my_info : Dictionary

func _ready():
	host_btn.connect("pressed", self, "on_menu_hostBtn_pressed")
	join_btn.connect("pressed", self, "on_menu_joinBtn_pressed")
	host_lobby_entry.hide()
	join_lobby_list.hide()
	name_entry.hide()

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
	var lobby_name = yield(host_lobby_entry, "text_entered")
	host_lobby_entry.hide()
	Gotm.host_lobby(false)
	Gotm.lobby.hidden = false
	Gotm.lobby.name = lobby_name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT)
	get_tree().set_network_peer(peer)
	get_tree().connect("network_peer_connected", self, "on_player_connected")
	print("%s hosting " % [get_tree().get_network_unique_id()])

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
	join_lobby_list.set_lobbies(lobbies)
	join_lobby_list.show()
	var lobby : GotmLobby = yield(join_lobby_list, "lobby_selected")
	join_lobby_list.hide()
	print("Joining lobby: %s" % lobby.name)
	var success = yield(lobby.join(), "completed")
	if not success:
		print("Could not join lobby :(")
		return
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(lobby.host.address, PORT)
	get_tree().set_network_peer(peer)
	yield(get_tree(), "connected_to_server")
	rpc("register_player", my_info)

func on_player_connected(id) -> void:
	# inform the client who just connected about the host
	rpc_id(id, "register_player", my_info)

remotesync func register_player(info : Dictionary) -> void:
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	print(player_info)