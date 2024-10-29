extends RayCast3D

class_name PlayerInteractor

@export var player: Character
var active_area: InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player)

func _input(event):
	pass
	# if !is_multiplayer_authority():
	# 	return false

	# if event.is_action_pressed("interact"):
	# 	# TODO: needs to send rpc to server to check this info before calling interact for that player
	# 	if active_area != null:
	# 		print(player.get_multiplayer_authority(), " sent rpc to server")
	# 		InteractionManager.rpc_id(1, "is_valid_interact", active_area.get_path())
	# 		InteractionManager.label.hide()

	# 	# if active_area != null:
	# 	# 	can_interact = false
	# 	# 	InteractionManager.label.hide()

	# 	# 	# TODO: does this call need to happen on local or server
	# 	# 	await active_area.interact.call()

	# 	# 	can_interact = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	# # if multiplayer.is_server():
	# # 	print(player, "status can_interact=", can_interact, " and is_colliding()=", is_colliding())
	# if is_colliding():
	# 	active_area = get_collider()

	# 	if is_multiplayer_authority() and InteractionManager.label.hidden:
	# 		print(player, " should be showing the text ", active_area.actionName)
	# 		InteractionManager.set_interaction_label_text(active_area.actionName)
	# 		InteractionManager.label.show()
	# 	# print(player, " looking at ", active_area)

	# 	if multiplayer.is_server():
	# 		InteractionManager.register_area(active_area, player)

	# else:
	# 	active_area = null

	# 	if !InteractionManager.label.hidden:
	# 		InteractionManager.label.hide()
	# 	# print(player, " looking at nothing")

	# 	if multiplayer.is_server():
	# 		InteractionManager.unregister_area(player)