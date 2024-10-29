extends RayCast3D

class_name PlayerInteractor

@export var player: Character
var activeInteractable: InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player)

func _input(event):
	if !is_multiplayer_authority():
		return false

	if event.is_action_pressed("interact"):
		# TODO: needs to send rpc to server to check this info before calling interact for that player
		if activeInteractable != null:
			print(player.get_multiplayer_authority(), " sent rpc to server")
			InteractionManager.rpc_id(1, "is_valid_interact", activeInteractable.get_path())
			InteractionManager.label.hide()

		# if activeInteractable != null:
		# 	can_interact = false
		# 	InteractionManager.label.hide()

		# 	# TODO: does this call need to happen on local or server
		# 	await activeInteractable.interact.call()

		# 	can_interact = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# if multiplayer.is_server():
	# 	print(player, "status can_interact=", can_interact, " and is_colliding()=", is_colliding())
	if is_colliding():

		if is_multiplayer_authority():
			activeInteractable = get_collider()
			InteractionManager.set_interaction_label_text(activeInteractable.actionName)
			InteractionManager.label.show()
		# print(player, " looking at ", activeInteractable)

		if multiplayer.is_server():
			InteractionManager.register_area(activeInteractable, player)

	else:
		if is_multiplayer_authority():
			activeInteractable = null
			InteractionManager.label.hide()
		# print(player, " looking at nothing")

		if multiplayer.is_server():
			InteractionManager.unregister_area(player)
