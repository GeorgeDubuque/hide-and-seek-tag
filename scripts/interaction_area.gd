# InteractionArea.gd
extends Area3D
class_name InteractionArea

@export var actionName: String = "interact"

var collider: CollisionShape3D

var interact: Callable = func(playerInteractorId: int):
	pass

func _ready() -> void:
	collider = get_child(0)

# Method to enable the collider for interaction
func enable():
	collider.disabled = false
	print("interaction area enabling collider: ", collider.get_path())

# Method to disable the collider for interaction
func disable():
	collider.disabled = true
	print("interaction area disabling collider: ", collider.get_path())

# Method to handle interaction from the client
@rpc("call_local", "any_peer", "reliable")
func handle_interaction(player_id):
	if multiplayer.is_server():
		print("Server received interaction request from player: ", player_id)
		# Notify the parent object to handle the interaction (for example, toggle light)
		interact.call(player_id)
