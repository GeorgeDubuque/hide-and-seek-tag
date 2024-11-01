class_name PlayerSpawner
extends MultiplayerSpawner

@export var playerScene: PackedScene

@export_group("Lobby Settings")
@export var spawns: Array[Node3D]
@export var minNumPlayers = 2

@export_group("References")
@export var startGameButton: Button
@export var testLevelPath = ""

var spawnPos = Vector3(0, 0, 0)

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
	var p: Player = playerScene.instantiate()
	p.player = data
	GameManager.addPlayer(data, p)
	# var nextSpawn = spawns.pop_front()
	# p.position = nextSpawn.position
	# spawns.push_back(nextSpawn)
	p.position = spawnPos
	spawnPos += Vector3(2, 0, 0)
	players[data] = p

	# if multiplayer.is_server():
	# 	if players.size() >= minNumPlayers:
	# 		startGameButton.show()


	return p


func removePlayer(data):
	print("player ", data, " has left")
	print("removing from id_to_player map")
	GameManager.id_to_players.erase(data)
	print("removing from id_to_status map")
	GameManager.id_to_status.erase(data)
	players[data].queue_free()
	players.erase(data)


func _on_start_game_button_pressed() -> void:
	GameManager.change_level.call_deferred(testLevelPath, true)
	startGameButton.hide()
