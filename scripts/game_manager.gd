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
	var randomTaggerIndex = randi_range(0, characters.size())

	var curr_index = 0
	for character in characters:
		if curr_index == randomTaggerIndex:
			print("set tagger: ", character)
		else:
			print("set hider: ", character)
		curr_index += 1
