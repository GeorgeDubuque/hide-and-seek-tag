extends Area3D

@export var my_body: Node3D
var tags = {}
@export var INTERACT: String = "interact"

var last_taggee = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		if Input.is_action_pressed(INTERACT) and last_taggee != null:
			print("tag local: ", last_taggee)
			check_can_tag.rpc_id(1, last_taggee)

@rpc("any_peer", "call_local", "reliable")
func check_can_tag(taggee_id):
	print("rpc called")
	if multiplayer.is_server():
		print("tagger ", multiplayer.get_remote_sender_id(), " tried to tag ", taggee_id)


func _on_body_entered(body: Node3D) -> void:
	if body.get_instance_id() != my_body.get_instance_id():
		print(get_multiplayer_authority(), " can tag ", body.get_multiplayer_authority())
		last_taggee = body.get_multiplayer_authority()
		if multiplayer.is_server():
			tags[get_multiplayer_authority()] = body.get_multiplayer_authority()

		# TODO: add this body to a list of objects in array 
