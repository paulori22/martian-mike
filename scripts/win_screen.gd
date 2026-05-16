extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func update_session_stats():
	$Stats/TotalTime.text = "Time: " + PlayerData.get_formatted_played_time()
	$Stats/Deaths.text = "Deaths: " + str(PlayerData.get_deaths())
