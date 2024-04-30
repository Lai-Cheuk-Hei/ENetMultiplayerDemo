extends Control

@export var PlayerScene : PackedScene
var rng = RandomNumberGenerator.new()

var player_index
var server_closed = false

signal close_server

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only host can close server
	if multiplayer.get_unique_id() == 1:
		$CloseServerButton.disabled = false
	
	#print(GameManager.Players)
	for i in GameManager.Players:
		# Player list display
		var label = Label.new()
		label.text = GameManager.Players[i].name
		if(multiplayer.get_unique_id() == GameManager.Players[i].id):
			label.add_theme_color_override("font_color", Color(1,1,0,1))
			player_index = i
		$PlayerList/VBoxContainer.add_child(label)
		
		# Init players
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		currentPlayer.player_name = str(GameManager.Players[i].name)
		var rng_x = rng.randf_range(128.0, self.size.x - 128.0)
		var rng_y = rng.randf_range(128.0, self.size.y - 128.0)
		currentPlayer.position = Vector2(rng_x, rng_y)
		$Players.add_child(currentPlayer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer","call_local")
func SetLabel(text, color = Color(1,1,1,1)):
	$ErrorLabel.text = text
	$ErrorLabel.add_theme_color_override("font_color", color)

@rpc("any_peer","call_local")
func CloseServerStatus():
	server_closed = true

func _on_close_server_button_pressed():
	$ErrorLabel.text = "Server closed by host.\nPlease wait to return to main screen."
	SetLabel.rpc("Server closed by host.\nPlease wait to return to main screen.", Color(1,0,0,1))
	CloseServerStatus.rpc()
	close_server.emit()
	pass # Replace with function body.


func _on_action_button_pressed():
	if not server_closed:
		SetLabel.rpc(GameManager.Players[player_index].name + " acted.")
	pass # Replace with function body.
