extends Control

@export var PlayerScene : PackedScene
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#print(GameManager.Players)
	for i in GameManager.Players:
		#print(i)
		var label = Label.new()
		label.text = GameManager.Players[i].name
		if(multiplayer.get_unique_id() == GameManager.Players[i].id):
			label.add_theme_color_override("font_color", Color(1,1,0,1))
		$PlayerList/VBoxContainer.add_child(label)
		
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		currentPlayer.player_name = str(GameManager.Players[i].name)
		var rng_x = rng.randf_range(128.0, self.size.x - 128.0)
		var rng_y = rng.randf_range(128.0, self.size.y - 128.0)
		currentPlayer.position = Vector2(rng_x, rng_y)
		add_child(currentPlayer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
