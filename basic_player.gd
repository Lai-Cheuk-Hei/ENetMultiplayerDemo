extends CharacterBody2D
 
@export var player_name = ""

func _ready():
	$Label.text = player_name
	if is_multiplayer_authority():
		$Label.add_theme_color_override("font_color", Color(1,1,0,1))

func _enter_tree():
	set_multiplayer_authority(name.to_int())
 
func _physics_process(delta):
	#$Label.text = player_name
	if is_multiplayer_authority():
		velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 400
	move_and_slide()
 
