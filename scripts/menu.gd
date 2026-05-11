extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var info_panel: Panel = $InfoPanel


func _ready():
	main_buttons.visible = true
	info_panel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Pressing start button will go to the game scene
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/town.tscn")

# When pressing "How to play" button, a panel will pop up containing info
func _on_info_button_pressed() -> void:
	main_buttons.visible = false
	info_panel.visible = true

# Pressing exit button will exit the game
func _on_exit_button_pressed() -> void:
	get_tree().quit()

# Pressing back button (from "How to play" panel) will go back to main menu
func _on_back_button_pressed() -> void:
	main_buttons.visible = true
	info_panel.visible = false
