extends Control

const text_theme = preload("res://base_theme.tres")

var opened_from_win_scene: bool = false

@onready var leaderboard_grid = $PanelContainer/VBoxContainer/ScrollContainer/LeaderboardGrid
@onready var vbox = $PanelContainer/VBoxContainer

var status_label: Label

func _ready() -> void:
	_setup_status_label()
	ApiManager.leaderboard_loaded.connect(_on_leaderboard_loaded)
	ApiManager.leaderboard_fetch_failed.connect(_on_leaderboard_fetch_failed)
	_show_status("Loading...", true)
	ApiManager.fetch_leaderboard()

func _setup_status_label() -> void:
	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.theme = text_theme
	status_label.add_theme_font_size_override(&"font_size", 14)
	status_label.visible = false
	vbox.add_child(status_label)
	vbox.move_child(status_label, 1)

static func format_time(total_seconds: int) -> String:
	var hours := int(total_seconds / 3600.0)
	var minutes := int((total_seconds % 3600) / 60.0)
	var seconds := total_seconds % 60
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	return "%02d:%02d" % [minutes, seconds]


static func format_date(iso_string: String) -> String:
	if iso_string.is_empty():
		return "—"
	var parts := iso_string.split("T")
	var date_part := parts[0]
	var date_segments := date_part.split("-")
	if date_segments.size() < 3:
		return iso_string
	var time_str := "00:00"
	if parts.size() > 1:
		var t := parts[1].split(".")[0]
		if t.ends_with("Z"):
			t = t.substr(0, t.length() - 1)
		elif t.length() > 8 and (t[8] == "+" or t[8] == "-"):
			t = t.substr(0, 8)
		var time_segments := t.split(":")
		if time_segments.size() >= 2:
			time_str = "%s:%s" % [time_segments[0], time_segments[1]]
	return "%s %s" % [date_part, time_str]


func _on_leaderboard_loaded(entries: Array) -> void:
	_clear_leaderboard_rows()

	if entries.is_empty():
		_show_status("No scores yet.", true)
		return

	_hide_status()

	for i in range(entries.size()):
		var entry: Variant = entries[i]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var pdata: Variant = entry.get("data", {})
		var time_sec := 0
		var deaths := 0
		if typeof(pdata) == TYPE_DICTIONARY:
			time_sec = int(pdata.get("time", 0))
			deaths = int(pdata.get("deaths", 0))

		var pname := str(entry.get("playerName", ""))
		var created := str(entry.get("createdAt", ""))

		leaderboard_grid.add_child(_make_cell_label(str(i + 1)))
		leaderboard_grid.add_child(_make_cell_label(pname))
		leaderboard_grid.add_child(_make_cell_label(format_time(time_sec)))
		leaderboard_grid.add_child(_make_cell_label(str(deaths)))
		leaderboard_grid.add_child(_make_cell_label(format_date(created)))

func _on_leaderboard_fetch_failed(message: String) -> void:
	_show_status(message, true)

func _clear_leaderboard_rows() -> void:
	while leaderboard_grid.get_child_count() > 5:
		var c := leaderboard_grid.get_child(leaderboard_grid.get_child_count() - 1)
		leaderboard_grid.remove_child(c)
		c.queue_free()

func _make_cell_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.theme = text_theme
	label.add_theme_font_size_override(&"font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _show_status(message: String, make_visible: bool) -> void:
	status_label.text = message
	status_label.visible = make_visible

func _hide_status() -> void:
	status_label.visible = false
	status_label.text = ""

func _on_back_btn_pressed() -> void:
	if opened_from_win_scene:
		# Just delete this overlay! 
		#The win scene is still alive underneath with all its data.
		queue_free()
	else:
		# Go back to the main menu normally
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
