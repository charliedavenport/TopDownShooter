extends Control

signal lobby_selected(lobby)

const lobby_entry_scene = preload("res://Menu/LobbyEntry.tscn")

onready var lobby_list = get_node("JoinLobbyList")

func set_lobbies(lobbies : Array) -> void:
	for lobby in lobbies:
		var lobby_entry = lobby_entry_scene.instance()
		lobby_entry.lobby = lobby
		lobby_entry.get_node("Label").text = lobby.name
		lobby_entry.connect("join_pressed", self, "on_join_pressed")
		lobby_list.call_deferred("add_child", lobby_entry)

func on_join_pressed(lobby) -> void:
	emit_signal("lobby_selected", lobby)
