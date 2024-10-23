class_name PlayerSpawner
extends MultiplayerSpawner

@export var playerScene: PackedScene

@export_group("Lobby Settings")
@export var spawns: Array[Node3D]
@export var minNumPlayers = 2

@export_group("References")
@export var startGameButton: Button
@export var testLevelPath = ""

var players = {}

# Called when the node enters the scene tree for the first time.
func spawn_players() -> void:
	spawn_path = get_tree().get_root().get_node("Main").get_node("Players").get_path()
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_on_start_game_button_pressed()

func spawnPlayer(data):
	var p: Node3D = playerScene.instantiate()
	var nextSpawn = spawns.pop_front()
	p.position = nextSpawn.position
	spawns.push_back(nextSpawn)
	p.set_multiplayer_authority(data)
	players[data] = p

	if multiplayer.is_server():
		if players.size() >= minNumPlayers:
			startGameButton.show()


	return p


func removePlayer(data):
	players[data].queue_free()
	players.erase(data)


func _on_start_game_button_pressed() -> void:
	var current_node = get_parent() # Start with the parent node
	while current_node != null:
		if current_node is Main:
			startGameButton.hide()
			(current_node as Main).change_level.call_deferred(testLevelPath)
		current_node = current_node.get_parent() # Move up to the next parent node
