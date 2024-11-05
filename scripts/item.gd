extends Node3D
class_name Item


@export var playerInput: PlayerInput
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var use_item: Callable = func():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !multiplayer.is_server() || playerInput == null:
		return

	if playerInput.use_item_button_just_pressed:
		use_item.call()

	playerInput.use_item_button_just_pressed = false
