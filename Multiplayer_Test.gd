extends Node2D
 
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

@export var Address = "192.168.32.55"
@export var port = 8910

var player_name : String
 
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	if "--server" in OS.get_cmdline_args():
		hostGame()
	
func hostGame():
	var error = peer.create_server(port)
	if error != OK:
		print("cannot host: " + error)
		return
	else:
		print("Now hosting on: " + Address + ":" + str(port))
	multiplayer.multiplayer_peer = peer
	#SendPlayerInformation($TextEdit.text, multiplayer.get_unique_id())

func _on_host_pressed():
	hostGame()
	SendPlayerInformation($TextEdit.text, multiplayer.get_unique_id())
 
# this get called on the server and clients
func peer_connected(id):
	print("Player Connected " + str(id))

# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

func connected_to_server():
	print("connected To Sever!")
	SendPlayerInformation.rpc_id(1, $TextEdit.text, multiplayer.get_unique_id())


@rpc("any_peer")
func SendPlayerInformation(name, id):
	#print(name)
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"score": 0
		}
		
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
			
	for i in $PlayerList.get_children():
		if i != $PlayerList/Header:
			i.queue_free()
		
	for i in GameManager.Players:
		var label = Label.new()
		label.text = GameManager.Players[i].name
		if(multiplayer.get_unique_id() == GameManager.Players[i].id):
			label.add_theme_color_override("font_color", Color(1,1,0,1))
		$PlayerList.add_child(label)
 

func _on_join_pressed():
	peer.create_client(Address, port)
	multiplayer.multiplayer_peer = peer
 

func _on_text_edit_text_changed(new_text):
	player_name = $TextEdit.text
	#print(player_name)
	pass # Replace with function body.

@rpc("any_peer","call_local")
func StartGame():
	var scene = load("res://game_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_start_game_pressed():
	StartGame.rpc()
	pass # Replace with function body.
