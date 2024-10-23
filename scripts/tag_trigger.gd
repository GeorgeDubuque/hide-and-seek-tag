extends Area3D

@export var my_body: Node3D
var potential_tags = {}
var tags = {}
@export var INTERACT: String = "interact"
@export var character: Character

var last_taggee = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority():

		# handles tagging 

		# TODO: may not need last_taggee as we are already storing the last
		#		taggee on the server side, but helps so we dont send rpcs
		#		if their is no taggee on the clients side
		if Input.is_action_just_pressed(INTERACT) and last_taggee != null:
			try_tag_player.rpc_id(1, last_taggee) # 1 is the server id

# Check on server if a player can be tagged and if they can freeze their input
@rpc("any_peer", "call_local", "reliable")
func try_tag_player(taggee_id):
	if multiplayer.is_server():
		var tagger_id = multiplayer.get_remote_sender_id()
		print("tagger ", tagger_id, " tried to tag ", taggee_id)
		if potential_tags.has(tagger_id) and potential_tags[tagger_id] == taggee_id:
			print("tagger ", tagger_id, " TAGGED ", taggee_id)
			character.freeze_player.rpc_id(taggee_id)


# sets potential tag for this game object 
func _on_body_entered(body: Node3D) -> void:
	if body.get_instance_id() != my_body.get_instance_id():
		var tagger_id = get_multiplayer_authority()
		var taggee_id = body.get_multiplayer_authority()

		# TODO: this could potentially cause problems if multiple people are in the taggers tag box
		#		consider storing a list of taggees and getting the closest one
		last_taggee = taggee_id

		if multiplayer.is_server():
			potential_tags[tagger_id] = taggee_id
			print(tagger_id, " can tag ", taggee_id)

		# TODO: add this body to a list of objects in array 

# removes potential tag if taggee is no longer in tag box
func _on_body_exited(body: Node3D) -> void:
	if body.get_instance_id() != my_body.get_instance_id():
		var tagger_id = get_multiplayer_authority()

		last_taggee = null

		if multiplayer.is_server():
			potential_tags.erase(tagger_id)
