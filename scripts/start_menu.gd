extends Control

@onready var start_btn = $Start
@onready var quit_btn = $Quit

func _ready() -> void:
	start_btn.connect("pressed", start)
	quit_btn.connect("pressed", quit)

func start():
	get_tree().change_scene_to_file("res://scenes/level.tscn")
	PlayerData.reset_player_data()

func quit():
	get_tree().quit()
