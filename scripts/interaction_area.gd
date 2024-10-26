extends Area3D
class_name InteractionArea

@export var actionName: String = "interact"

var interact: Callable = func():
	pass

func _on_area_entered(area: Area3D) -> void:
	InteractionManager.register_area(self)


func _on_area_exited(area: Area3D) -> void:
	InteractionManager.unregister_area(self)
