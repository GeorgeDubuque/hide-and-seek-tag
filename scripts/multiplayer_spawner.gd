extends MultiplayerSpawner

@export var playerScene: PackedScene
@export var spawns: Array[Node3D]

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		print("ready called with authority: ", get_multiplayer_authority())
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func spawnPlayer(data):
	print("spawnPlayer called with data: ", data)
	var p: Node3D = playerScene.instantiate()
	var nextSpawn = spawns.pop_front()
	p.position = nextSpawn.position
	spawns.push_back(nextSpawn)
	p.set_multiplayer_authority(data)
	players[data] = p

	return p


func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
