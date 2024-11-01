extends MultiplayerSynchronizer

@export var JUMP: String = "jump"
@export var LEFT: String = "ui_left"
@export var RIGHT: String = "ui_right"
@export var FORWARD: String = "ui_up"
@export var BACKWARD: String = "ui_down"
## By default this does not pause the game, but that can be changed in _process.
@export var PAUSE: String = "ui_cancel"
@export var CROUCH: String = "crouch"
@export var SPRINT: String = "sprint"

@export var input_direction := Vector2()
@export var jumping := false
@export var sprinting_just_pressed := false
@export var sprinting_pressed := false
@export var crouch_just_pressed := false
@export var crouch_pressed := false
@export var mouse_input := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process_unhandled_input(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	input_direction = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	sprinting_just_pressed = Input.is_action_just_pressed(SPRINT)
	sprinting_pressed = Input.is_action_pressed(SPRINT)
	crouch_just_pressed = Input.is_action_just_pressed(CROUCH)
	crouch_pressed = Input.is_action_pressed(CROUCH)

	if Input.is_action_pressed(JUMP) or Input.is_action_just_pressed(JUMP):
		jump.rpc()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input.x += event.relative.x
		mouse_input.y += event.relative.y