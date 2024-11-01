extends Area3D
class_name InteractionArea

@export var actionName: String = "interact"

var collider: CollisionShape3D

func _ready() -> void:
	collider = get_child(0)

var interact: Callable = func(interactor: PlayerInteractor):
	pass
