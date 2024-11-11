extends Area3D
class_name InteractionArea

@export var actionName: String = "interact"

var collider: CollisionShape3D

func _ready() -> void:
	collider = get_child(0)

var interact: Callable = func(interactor: PlayerInteractor):
	pass

func enable():
	collider.disabled = false
	print("interaction area enabling collider: ", collider.get_path())

func disable():
	collider.disabled = true
	print("interaction area disabling collider: ", collider.get_path())