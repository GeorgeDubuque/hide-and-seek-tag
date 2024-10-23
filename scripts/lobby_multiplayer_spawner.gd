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
func _ready() -> void:
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

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
	spawn_function = spawn_level
	spawn(testLevelPath)
	startGameButton.hide()
