extends RayCast3D

class_name PlayerInteractor

@export var player: Player
@export var interactLabel: Label
@export var player_input: PlayerInput
var activeInteractable: InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# print(player)

# func _input(event):
# 	if !is_multiplayer_authority():
# 		return false
# 
# 	if event.is_action_pressed("interact"):
# 		if activeInteractable != null:
# 			print(player, " with id ", player.multiplayer.get_unique_id(), " tried to interact with ", activeInteractable)
# 			print(player, " client is sending rpc to server to check if interaction was valid")
# 			InteractionManager.rpc_id(1, "is_valid_interact", activeInteractable.get_path())
# 			InteractionManager.label.hide()

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server():
		return

	if player_input.interact_button_just_pressed:
		if activeInteractable != null:
			# print(player, " with id ", player.multiplayer.get_unique_id(), " tried to interact with ", activeInteractable)
			# print(player, " client is sending rpc to server to check if interaction was valid")
			activeInteractable.interact.call()
			# InteractionManager.rpc_id(1, "is_valid_interact", activeInteractable.get_path())
			# InteractionManager.label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !multiplayer.is_server():
		return

	if is_colliding():
		activeInteractable = get_collider()
		# print(player, " looking at ", activeInteractable)
	else:
		activeInteractable = null
		# print(player, " looking at nothing")

	if activeInteractable != null:
		interactLabel.text = "[E] to " + activeInteractable.actionName
		interactLabel.show()
		# InteractionManager.set_interaction_label_text(activeInteractable.actionName)
		# InteractionManager.label.show()
	else:
		interactLabel.hide()
		# InteractionManager.label.hide()

	# if is_multiplayer_authority():
	# 	if is_colliding():
	# 		activeInteractable = get_collider()
	# 		# print(player, " looking at ", activeInteractable)
	# 	else:
	# 		activeInteractable = null
	# 		# print(player, " looking at nothing")

	# 	if activeInteractable != null:
	# 		InteractionManager.set_interaction_label_text(activeInteractable.actionName)
	# 		InteractionManager.label.show()
	# 	else:
	# 		InteractionManager.label.hide()

	# if multiplayer.is_server():
	# 	if is_colliding():
	# 		InteractionManager.register_area(get_collider(), player)
	# 	else:
	# 		InteractionManager.unregister_area(player)
