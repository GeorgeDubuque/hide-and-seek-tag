extends Area3D

@export var my_body: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.get_instance_id() != my_body.get_instance_id():
		print("tagger entered body: ", body)
		if multiplayer.is_server():
			print("add ", body.name, " to array")

		# TODO: add this body to a list of objects in array 
