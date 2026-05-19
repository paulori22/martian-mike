extends Control

var leaderboard_scene = preload("res://scenes/leaderboard.tscn")

func _ready() -> void:
	ApiManager.leaderboard_entry_submitted_successfully.connect(_on_leaderboard_entry_submitted_successfully)
	ApiManager.leaderboard_entry_submission_failed.connect(_on_leaderboard_entry_submission_failed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func update_session_stats():
	$Stats/TotalTime.text = "Time: " + PlayerData.get_formatted_played_time()
	$Stats/Deaths.text = "Deaths: " + str(PlayerData.get_deaths())

func _on_leaderboard_pressed() -> void:
	var instantiate_scene = leaderboard_scene.instantiate()
	instantiate_scene.opened_from_win_scene = true
	# Add it to the screen on top of the win elements
	add_child(instantiate_scene)

func _on_submit_leaderboard_pressed() -> void:
	var player_name = $LeaderboardSubmit/PlayerNameField.text
	var time_sec = int(PlayerData.get_played_time())
	var deaths = PlayerData.get_deaths()
	ApiManager.submit_leaderboard_entry(player_name, time_sec, deaths)

func _on_leaderboard_entry_submitted_successfully() -> void:
	$LeaderboardSubmit/SubmitLeaderboardBtn.disabled = true
	_set_and_show_response_message("✅ Synced with server")

func _on_leaderboard_entry_submission_failed(message: String) -> void:
	_set_and_show_response_message("❌ " + message)

func _set_and_show_response_message(message: String) -> void:
	$LeaderboardSubmit/ResponseMessage.text = message
	$LeaderboardSubmit/ResponseMessage.visible = true
