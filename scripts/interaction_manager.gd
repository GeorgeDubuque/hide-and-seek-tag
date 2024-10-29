extends Node3D

@onready var label: Label = $Label_Interact

const base_text = "[E] to "

var active_areas = {}
var can_interact = true

@rpc("call_local", "any_peer", "reliable")
func is_valid_interact(area_path: NodePath):
	var player_id = multiplayer.get_remote_sender_id()
	print("interaction manager recieved rpc from ", player_id)
	if !active_areas.has(player_id):
		print("server doesnt have the player requested on is_valid_interact")
		return

	var playerArea = active_areas[player_id]
	if playerArea != null and area_path == playerArea.get_path():
		print("player ", player_id, " interacted with ", area_path)
		playerArea.interact.call()
	else:
		print("player ", player_id, " tried to interact with ", area_path, " but server had ", playerArea)


func register_area(area: InteractionArea, player: Character): # TODO: this should accept player id
	var playerId = player.get_multiplayer_authority() # TODO: this assumes all players own themselves
	active_areas[playerId] = area

func unregister_area(player: Character):
	var playerId = player.get_multiplayer_authority() # TODO: this assumes all players own themselves
	active_areas[playerId] = null

func set_interaction_label_text(text: String):
	label.text = base_text + text
