extends Node

var id_to_characters = {}
var tagger
var hiders = []

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
	var characters = id_to_characters.values()
	var randomTaggerIndex = randi_range(0, characters.size() - 1)

	var curr_index = 0
	for id in id_to_characters:
		var character = id_to_characters[id]
		if curr_index == randomTaggerIndex:
			print("set tagger: ", character)
			character.set_player_type.rpc(globals.PlayerType.TAGGER)
		else:
			print("set hider: ", character)
			character.set_player_type.rpc(globals.PlayerType.HIDER)
		curr_index += 1
