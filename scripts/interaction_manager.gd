extends Node3D

@onready var label: Label = $Label_Interact

const base_text = "[E] to "

var active_areas = {}
var can_interact = true

@rpc("call_local", "any_peer", "reliable")
func is_valid_interact(area_path: NodePath):
	var player_id = multiplayer.get_remote_sender_id()
	print("server recieved is_valid_interact from ", GameManager.id_to_players[player_id], " on ", area_path)
	# print("interaction manager recieved rpc from ", player_id)
	if !active_areas.has(player_id):
		print("server doesnt have the player requested on is_valid_interact")
		return

	var playerArea = active_areas[player_id] # what the server thinks the player is interacting with
	if playerArea != null and area_path == playerArea.get_path():
		print("server calling interact on ", area_path, " for player ", GameManager.id_to_players[player_id])
		playerArea.interact.call()
	else:
		print("player ", player_id, " tried to interact with ", area_path, " but server had ", playerArea)


func register_area(area: InteractionArea, player: Player): # TODO: this should accept player id
	var playerId = player.get_multiplayer_authority() # TODO: this assumes all players own themselves
	active_areas[playerId] = area

func unregister_area(player: Player):
	var playerId = player.get_multiplayer_authority() # TODO: this assumes all players own themselves
	active_areas[playerId] = null

func set_interaction_label_text(text: String):
	label.text = base_text + text
