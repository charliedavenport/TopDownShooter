extends Control

const playerLobbyPanelScene = preload("res://Menu/PlayerLobbyPanel.tscn")

onready var vbox = get_node("VBoxContainer")

signal player_ready(name)

func add_player(name : String, network_id,  is_local : bool) -> void:
	var player_panel = playerLobbyPanelScene.instance()
	player_panel.set_name(name)
	player_panel.enable_ready_btn(is_local)
	vbox.add_child(player_panel)
	player_panel.get_node("Button").connect("pressed", self, "on_btn_pressed", [name])

func on_btn_pressed(name) -> void:
	emit_signal("player_ready", name)


