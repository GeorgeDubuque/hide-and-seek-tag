extends Node

var id_to_characters = {}
var taggers = []
var hiders = []

var numTaggers = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func addPlayer(playerId, character: Character):
	if !id_to_characters.has(playerId):
		id_to_characters[playerId] = character

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
	for character in chosenTaggers:
		character.set_player_type.rpc(globals.PlayerType.TAGGER)
	
	# set hiders
	for character in available_characters:
		character.set_player_type.rpc(globals.PlayerType.HIDER)

func placePlayers(level: GameLevel):
	level.hiderSpawns
	level.taggerSpawn
