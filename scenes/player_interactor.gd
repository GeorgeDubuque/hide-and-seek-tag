extends RayCast3D

class_name PlayerInteractor

@export var player: Character
var active_area: InteractionArea
var can_interact = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player)

func _input(event):
	if !is_multiplayer_authority():
		return false

	if event.is_action_pressed("interact") and can_interact:
		# TODO: needs to send rpc to server to check this info before calling interact for that player
		if active_area != null:
			print("player sent rpc to server")
			InteractionManager.rpc_id(1, "is_valid_interact", active_area.get_path())

		# if active_area != null:
		# 	can_interact = false
		# 	InteractionManager.label.hide()

		# 	# TODO: does this call need to happen on local or server
		# 	await active_area.interact.call()

		# 	can_interact = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if multiplayer.is_server():
		print(player, "status can_interact=", can_interact, " and is_colliding()=", is_colliding())
	if is_colliding() && can_interact:
		active_area = get_collider()

		if InteractionManager.label.hidden:
			InteractionManager.set_interaction_label_text(active_area.actionName)
			InteractionManager.label.show()
		print(player, " looking at ", active_area)

		if multiplayer.is_server():
			print("registering interaction area ", active_area, " for player ", player)
			InteractionManager.register_area(active_area, player)

	else:
		InteractionManager.label.hide()
		active_area = null

		if !InteractionManager.label.hidden:
			InteractionManager.label.hide()
		# print(player, " looking at nothing")

		if multiplayer.is_server():
			InteractionManager.unregister_area(player)
