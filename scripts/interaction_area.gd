class_name InteractionArea
extends Area3D

@export var actionName: String = "interact"

var interact: Callable = func():
	pass


func _on_body_exited(body: Node3D) -> void:
	InteractionManager.unregister_area(self)

func _on_body_entered(body: Node3D) -> void:
	print("interactable had body entered: ", body)
	InteractionManager.register_area(self)
