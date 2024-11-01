extends Node

var id_to_players = {}
var taggers = []
var hiders = []
var frozenHiders = {}
var numTaggers = 1
var id_to_status = {}
var levelNode
var gameStatus = globals.GameStatus.LOBBY

const minNumPlayersToStartGame = 1
const lobbyLevelPath = "res://scenes/levels/lobby_level.tscn"
const defaultLevelPath = "res://scenes/levels/game_level.tscn"
const lobbySpawnOffset = Vector3(2, 0, 0) # how far apart players should spawn from one another

@onready var startGameButton = $LobbyUI/StartGameButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levelNode = get_tree().root.get_node("Main/Level")
	# print("root node: ", levelNode)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func addPlayer(playerId, player: Player):
	playerId = player.player
	if !id_to_players.has(playerId):
		id_to_players[playerId] = player
		id_to_status[playerId] = globals.PlayerStatus.NONE
		if id_to_players.size() >= minNumPlayersToStartGame:
			startGameButton.show()

func assignPlayerTypes():
	var available_players = id_to_players.values()

	# choose taggers, store in array and remove from characters list
	var chosenTaggers = []
	print("available players: ", available_players)
	while chosenTaggers.size() < numTaggers:
		var randomTaggerIndex = randi_range(0, available_players.size() - 1)
		if available_players[randomTaggerIndex] not in chosenTaggers:
			chosenTaggers.append(available_players[randomTaggerIndex])
			available_players.remove_at(randomTaggerIndex)

	# set taggers
	taggers = chosenTaggers
	for player in chosenTaggers:
		print("assigning player ", player, "as TAGGER")
		player.set_player_type(globals.PlayerType.TAGGER)
	
	# set hiders
	hiders = available_players
	for player in available_players:
		print("assigning player ", player, "as HIDER")
		player.set_player_type(globals.PlayerType.HIDER)

func placePlayersInLobby():
	#place taggers
	var lastSpawnPos = Vector3(0, 0, 0)
	for player in id_to_players.values():
		# print("placing player ", player, " at position in lobby: ", lastSpawnPos)

		player.set_player_position.rpc(lastSpawnPos)

		# remove all status on player
		# player.set_player_status.rpc(globals.PlayerStatus.NONE)

		# TODO: need to remove all types from players and also disable all interaction
		#		areas on the players so no one can be tagged

		lastSpawnPos += lobbySpawnOffset

func load_lobby():
	if multiplayer.is_server():

		# Spawn Lobby Level
		var newLevel = load(lobbyLevelPath).instantiate()
		levelNode.add_child(newLevel)


		# Remove everthing BUT new level
		for c in levelNode.get_children():
			if c != newLevel:
				levelNode.remove_child(c)
				c.queue_free()

		placePlayersInLobby()
		startGameButton.show()
		gameStatus = globals.GameStatus.LOBBY

func placePlayers(level: GameLevel):
	#place taggers
	var lastTaggerSpawnPos: Vector3 = level.taggerSpawn.position
	for tagger in taggers:
		(tagger as Player).set_player_position.rpc(lastTaggerSpawnPos)
		# print("setting player ", tagger, " as tagger at position: ", lastTaggerSpawnPos)
		lastTaggerSpawnPos += Vector3(1, 0, 0)

	# place hiders
	var available_hider_spawns = level.hiderSpawns
	for hider in hiders:
		var randomHiderSpawnIndex = randi_range(0, available_hider_spawns.size() - 1)
		var randomSpawnPosition: Vector3 = available_hider_spawns[randomHiderSpawnIndex].position
		# print("setting player ", hider, " as hider at position: ", randomSpawnPosition)
		(hider as Player).set_player_position.rpc(randomSpawnPosition)
		available_hider_spawns.remove_at(randomHiderSpawnIndex)


func change_level(level_scene: PackedScene, shouldStartGame = false):
	if multiplayer.is_server():


		# Remove everthing BUT new level
		for c in levelNode.get_children():
			levelNode.remove_child(c)
			c.queue_free()

		# Spawn New Level
		var newLevel = level_scene.instantiate()
		levelNode.add_child(newLevel, true)


		placePlayers(newLevel as GameLevel)

		if shouldStartGame:
			gameStatus = globals.GameStatus.IN_GAME

		# assignPlayerTypes()

func unfreeze_all_players():
	for player_id in id_to_players:
		var player = id_to_players[player_id]
		# print("setting ", player, " status to: NONE")
		player.set_player_status.rpc(globals.PlayerStatus.NONE)
		id_to_status[player_id] = globals.PlayerStatus.NONE
		

@rpc("reliable", "any_peer", "call_local")
func setPlayerStatus(status: globals.PlayerStatus, peer_id):
	# var peer_id = multiplayer.get_remote_sender_id()
	print("server recieved setPlayerStatus rpc from ", id_to_players[peer_id])

	id_to_status[peer_id] = status
	print("server sending rpc on player ", id_to_players[peer_id], " with status ", status)
	id_to_players[peer_id].set_player_status.rpc(status)

	# print("setting player ", peer_id, " to status ", str(status))

	var frozenCount = 0
	for currStatus in id_to_status.values():
		if currStatus == globals.PlayerStatus.FROZEN:
			frozenCount += 1

	if frozenCount == hiders.size():
		# print("taggers win!!!")
		unfreeze_all_players.call_deferred()
		load_lobby.call_deferred()


func _on_start_game_button_pressed() -> void:
	change_level.call_deferred(load(defaultLevelPath), true)
	assignPlayerTypes.call_deferred()
	startGameButton.hide()
