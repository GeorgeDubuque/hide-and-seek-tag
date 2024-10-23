extends Node3D

var AppId = "480"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.set_environment("SteamAppID", AppId)
	OS.set_environment("SteamGameID", AppId)
	Steam.steamInitEx()
	var isRunning = Steam.isSteamRunning()

	if !isRunning:
		print("ERROR: Steam not running")
		return
	print("Steam is running")

	var id = Steam.getSteamID()
	var name = Steam.getPersonaName()

	print("Id: ", id, " Username: ", name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Steam.run_callbacks()
