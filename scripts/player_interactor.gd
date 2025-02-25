# PlayerInteractor.gd
extends RayCast3D

class_name PlayerInteractor

@export var player: Player
@export var interactLabel: Label
@export var player_input: PlayerInput
var activeInteractable: InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Detect the active interactable area and send the interaction request to the server
func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	# Update the active interactable object
	if is_colliding():
		activeInteractable = get_collider() as InteractionArea
	else:
		activeInteractable = null
	# When the player presses the interact button, send an RPC to the server
	if player_input.interact_button_just_pressed and activeInteractable != null:
		print("Client sending RPC to server to interact with: ", activeInteractable)
		# Send the interaction request to the server via RPC
		activeInteractable.rpc_id(1, "handle_interaction", player.multiplayer.get_unique_id())
		player_input.interact_button_just_pressed = false
	# Update the interaction label
	if activeInteractable != null:
		interactLabel.text = "[E] to " + activeInteractable.actionName
		interactLabel.show()
	else:
		interactLabel.hide()
