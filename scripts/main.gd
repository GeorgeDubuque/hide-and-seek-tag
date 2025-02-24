class_name Main

extends Node3D

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

@export var lobbyLevelPath = ""
@export var testLevelPath = ""
@export var playerSpawner: PlayerSpawner

@onready var ms = $MultiplayerSpawner
@onready var lobbyIdInput: LineEdit = $UI/LobbyUI/LobbyIdInput
@onready var labelLobbyId: Label = $UI/LobbyUI/Label_LobbyId

var lobbyLevel: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("connecting on lobby created")
	ms.spawn_function = spawn_level
	# peer.lobby_created.connect(on_lobby_created)
	# Steam.lobby_match_list.connect(_on_lobby_match_list)
	# open_lobby_list()

# Custom spawn function for main function that spawns a level scene
func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

###################### ENET STUFF ############################

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

func _on_enet_host_pressed() -> void:
	become_host()

func _on_enet_join_pressed() -> void:
	join_as_player()

func become_host() -> void:
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)

	multiplayer.multiplayer_peer = server_peer

	print("Created ENET server.")

	lobbyLevel = ms.spawn(lobbyLevelPath)
	playerSpawner.spawn_players()
	hide_lobby_buttons()

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)

func _del_player(id: int):
	print("Player %s left the game!" % id)

func join_as_player() -> void:
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	print("Created ENET client_peer peer.")

	multiplayer.multiplayer_peer = client_peer

	playerSpawner.spawn_players()
	hide_lobby_buttons()

##################################################
# singal callback for when the host presses host button
func _on_host_pressed() -> void:
	lobby_id = peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	lobbyLevel = ms.spawn(lobbyLevelPath)
	playerSpawner.spawn_players()
	hide_lobby_buttons()

# singal callback for lobby list item button click for joining other lobbies
func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	labelLobbyId.text = "Lobby ID: " + str(lobby_id)
	playerSpawner.spawn_players()
	hide_lobby_buttons()

# called when a lobby is created 
func on_lobby_created(connected, id):
	print("on_lobby_created")
	if connected:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		labelLobbyId.text = "Lobby ID: " + str(lobby_id)
		# lobbyIdLabel.text = lobby_id
		print(lobby_id)
	else:
		print("not connected")

# requests list of lobbies for app based on worldwide distance
func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

# consumes signal from when lobby is requested, displays list of lobbies and sets
# up on click events for each lobby item in the list
func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var mem_count = Steam.getNumLobbyMembers(lobby)

		var but = Button.new()
		but.set_text(str(lobby_name, "| Player Count: ", mem_count))
		but.set_size(Vector2(100, 5))
		but.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		$UI/LobbyUI/LobbyContainer/Lobbies.add_child(but)

func _on_refresh_pressed() -> void:
	if $UI/LobbyUI/LobbyContainer/Lobbies.get_child_count() > 0:
		for n in $UI/LobbyUI/LobbyContainer/Lobbies.get_children():
			n.queue_free()
	open_lobby_list()


func hide_lobby_buttons():
	$UI/LobbyUI.hide()


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("spawned player: ", node)


func _on_join_by_lobb_id_button_pressed() -> void:
	join_lobby(int(lobbyIdInput.text))
