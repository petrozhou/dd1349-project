extends Area2D

@export_file() var next_scene_path: String = ""
@export var is_invisible = false 
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

func _ready():
	if is_invisible:
		$Sprite2D.texture = null
	sprite.visible = false
	var player = find_parent("CurrentScene").get_children().back().find_child("Player")
	player.player_entering_door_signal.connect(enter_door)
	player.player_entered_door_signal.connect(close_door)

func enter_door():
	anim_player.play("OpenDoor")

func close_door():
	anim_player.play("CloseDoor")

func door_closed():
	get_node(NodePath("/root/SceneManager")).transition_to_scene(next_scene_path)
