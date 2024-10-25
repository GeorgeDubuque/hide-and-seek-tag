extends Node

var id_to_characters = {}
var taggers = []
var hiders = []
var frozenHiders = {}
var numTaggers = 1
var id_to_status = {}
var levelNode

const lobbyLevelPath = "res://scenes/levels/lobby_level.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levelNode = get_tree().root.get_node("Main/Level")
	print("root node: ", levelNode)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func addPlayer(playerId, character: Character):
	if !id_to_characters.has(playerId):
		id_to_characters[playerId] = character
		id_to_status[playerId] = globals.PlayerStatus.NONE

func assignPlayerTypes():
	var available_characters = id_to_characters.values()

	# choose taggers, store in array and remove from characters list
	var chosenTaggers = []
	while chosenTaggers.size() < numTaggers:
		var randomTaggerIndex = randi_range(0, available_characters.size() - 1)
		if available_characters[randomTaggerIndex] not in chosenTaggers:
			chosenTaggers.append(available_characters[randomTaggerIndex])
			available_characters.remove_at(randomTaggerIndex)

	# set taggers
	taggers = chosenTaggers
	for character in chosenTaggers:
		character.set_player_type.rpc(globals.PlayerType.TAGGER)
	
	# set hiders
	hiders = available_characters
	for character in available_characters:
		character.set_player_type.rpc(globals.PlayerType.HIDER)

func placePlayersInLobby():
	#place taggers
	var lastSpawnPos = Vector3(0, 0, 0)
	for player in id_to_characters.values():
		print("placing player ", player, " at position in lobby: ", lastSpawnPos)
		player.global_position = lastSpawnPos
		lastSpawnPos += Vector3(0, 10, 0)

func load_lobby():
	if multiplayer.is_server():

		# Spawn Lobby Level
		var newLevel = load(lobbyLevelPath).instantiate()
		levelNode.add_child(newLevel)

		placePlayersInLobby()

		# Remove everthing BUT new level
		for c in levelNode.get_children():
			if c != newLevel:
				levelNode.remove_child(c)
				c.queue_free()

func placePlayers(level: GameLevel):
	#place taggers
	var lastTaggerSpawnPos = level.taggerSpawn.position
	for tagger in taggers:
		tagger.position = lastTaggerSpawnPos
		lastTaggerSpawnPos += Vector3(1, 0, 0)

	# place hiders
	var available_hider_spawns = level.hiderSpawns
	for hider in hiders:
		var randomHiderSpawnIndex = randi_range(0, available_hider_spawns.size() - 1)
		hider.position = available_hider_spawns[randomHiderSpawnIndex].position
		available_hider_spawns.remove_at(randomHiderSpawnIndex)


func change_level(level_scene):
	if multiplayer.is_server():

		# Spawn New Level
		var newLevel = load(level_scene).instantiate()
		levelNode.add_child(newLevel)

		assignPlayerTypes()

		# Remove everthing BUT new level
		for c in levelNode.get_children():
			if c != newLevel:
				levelNode.remove_child(c)
				c.queue_free()

		placePlayers(newLevel as GameLevel)

@rpc("reliable", "any_peer", "call_local")
func setPlayerStatus(peer_id, status: globals.PlayerStatus):
	id_to_status[peer_id] = status

	var frozenCount = 0
	for currStatus in id_to_status.values():
		if currStatus == globals.PlayerStatus.FROZEN:
			frozenCount += 1

	if frozenCount == hiders.size():
		print("taggers win!!!")
		load_lobby()
