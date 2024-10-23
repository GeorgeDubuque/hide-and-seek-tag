class_name Main

extends Node3D

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

@export var lobbyLevelPath = ""

@onready var ms = $MultiplayerSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("connecting on lobby created")
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_lobby_list()

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	ms.spawn(lobbyLevelPath)
	hide_lobby_buttons()

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	hide_lobby_buttons()

func on_lobby_created(connected, id):
	print("on_lobby_created")
	if connected:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)
	else:
		print("not connected")

func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var mem_count = Steam.getNumLobbyMembers(lobby)

		var but = Button.new()
		but.set_text(str(lobby_name, "| Player Count: ", mem_count))
		but.set_size(Vector2(100, 5))
		but.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		$LobbyContainer/Lobbies.add_child(but)

func _on_refresh_pressed() -> void:
	if $LobbyContainer/Lobbies.get_child_count() > 0:
		for n in $LobbyContainer/Lobbies.get_children():
			n.queue_free()
	open_lobby_list()


func hide_lobby_buttons():
	$Host.hide()
	$LobbyContainer/Lobbies.hide()
	$Refresh.hide()


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("spawned player: ", node)

func change_level(level_scene):
	ms.add_spawnable_scene(level_scene)
	if multiplayer.is_server():
		# print("START LEVEL: ", level_scene.resource_name)
		# Remove old level if any.
		var level = $Level
		var newLevel = load(level_scene).instantiate()
		level.add_child(newLevel)

		for c in level.get_children():
			if c != newLevel:
				level.remove_child(c)
				c.queue_free()
		# Add new level.
