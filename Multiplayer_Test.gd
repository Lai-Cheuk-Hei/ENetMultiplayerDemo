extends Control
 
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

@export var Address = "127.0.0.1"
@export var port = 8910

var player_name : String
 
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()
	
func hostGame():
	var error = peer.create_server(port)
	if error != OK:
		print("Cannot host: " + str(error))
		$ErrorLabel.add_theme_color_override("font_color", Color(1,0,0,1))
		$ErrorLabel.text = "Cannot host: " + str(error)
		return false
	else:
		print("Now hosting on: " + Address + ":" + str(port))
		$ErrorLabel.add_theme_color_override("font_color", Color(0,1,0,1))
		$ErrorLabel.text = "Now hosting on port: " + str(port)
		multiplayer.multiplayer_peer = peer
		return true
	#SendPlayerInformation($TextEdit.text, multiplayer.get_unique_id())

func _on_host_pressed():
	var host_success = hostGame()
	if host_success:
		$StartGame.disabled = false
		SendPlayerInformation($NameEdit.text, multiplayer.get_unique_id())
 
# this get called on the server and clients
func peer_connected(id):
	print("Player Connected " + str(id))

@rpc("any_peer","call_local")
func CloseServer():
	print("Server Closed")
	get_tree().root.get_node("GameScene").queue_free()
	peer.host.destroy()
	GameManager.Players = {}
	self.show()

# this get called on the server and clients
func peer_disconnected(id):
	if id == 1:
		print("Host Disconnected " + str(id))
		CloseServer.rpc()
	else:
		print("Player Disconnected " + str(id))
		GameManager.Players.erase(id)
		var players = get_tree().get_nodes_in_group("Player")
		for i in players:
			if i.name == str(id):
				i.queue_free()

func connected_to_server():
	print("Connected To Sever!")
	#$ErrorLabel.add_theme_color_override("font_color", Color(0,1,0,1))
	#$ErrorLabel.text = "Connected To Sever!"
	SendPlayerInformation.rpc_id(1, $NameEdit.text, multiplayer.get_unique_id())

# called only from clients
func connection_failed():
	print("Couldn't Connect")
	#$ErrorLabel.add_theme_color_override("font_color", Color(1,0,0,1))
	#$ErrorLabel.text = "Couldn't Connect"
	

@rpc("any_peer")
func SendPlayerInformation(name, id):
	# Save player data to GameManager
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"score": 0
		}
		
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
	
	# Updates player list in server
	for i in $PlayerList/VBoxContainer.get_children():
		i.queue_free()
		
	for i in GameManager.Players:
		var label = Label.new()
		label.text = GameManager.Players[i].name
		if(multiplayer.get_unique_id() == GameManager.Players[i].id):
			label.add_theme_color_override("font_color", Color(1,1,0,1))
		$PlayerList/VBoxContainer.add_child(label)
 

func _on_join_pressed():
	var error = peer.create_client(Address, port)
	if error != OK:
		print("Cannot join " + Address + ": " + str(error))
		$ErrorLabel.add_theme_color_override("font_color", Color(1,0,0,1))
		$ErrorLabel.text = "Cannot join " + Address + ": " + str(error)
		return
	else:
		print("Joined game: " + Address + ":" + str(port))
		$ErrorLabel.add_theme_color_override("font_color", Color(0,1,0,1))
		$ErrorLabel.text = "Joined game: " + Address + ":" + str(port)
	multiplayer.multiplayer_peer = peer
 

@rpc("any_peer","call_local")
func StartGame():
	var scene = load("res://game_scene.tscn").instantiate()
	scene.close_server.connect(CloseServer)
	get_tree().root.add_child(scene)
	# Updates player list in server
	for i in $PlayerList/VBoxContainer.get_children():
		i.queue_free()
	$ErrorLabel.text = ""
	self.hide()

func _on_start_game_pressed():
	StartGame.rpc()
	pass # Replace with function body.


func _on_name_edit_text_changed(new_text):
	player_name = new_text
	pass # Replace with function body.


func _on_address_edit_text_changed(new_text):
	Address = new_text
	pass # Replace with function body.


func _on_port_edit_text_changed(new_text):
	port = int(new_text)
	pass # Replace with function body.
