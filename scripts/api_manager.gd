extends Node

signal leaderboard_loaded(entries: Array)
signal leaderboard_fetch_failed(message: String)
signal leaderboard_entry_submitted_successfully
signal leaderboard_entry_submission_failed(message: String)

var api_url: String = ""
var api_key: String = ""

func _ready() -> void:
	var env := _load_env("res://.env")
	if env.is_empty():
		push_error("Failed to load .env file.")
		return

	if not env.has("API_URL") or not env.has("API_KEY"):
		push_error("Missing required keys in .env file (API_URL, API_KEY).")
		return

	api_url = env["API_URL"]
	api_key = env["API_KEY"]


func _load_env(path: String) -> Dictionary:
	var env: Dictionary = {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return env

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var separator_index := line.find("=")
		if separator_index == -1:
			continue

		var key := line.substr(0, separator_index).strip_edges()
		var value := line.substr(separator_index + 1).strip_edges()
		env[key] = value

	file.close()
	return env


func _get_headers() -> PackedStringArray:
	return PackedStringArray([
		"X-API-KEY: %s" % api_key,
		"Content-Type: application/json"
	])


func fetch_leaderboard() -> void:
	if api_url.is_empty() or api_key.is_empty():
		push_error("API config not loaded. Check your .env file.")
		leaderboard_fetch_failed.emit("API config not loaded.")
		return
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(
		func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
			_on_leaderboard_request_completed(http_request, result, response_code, body)
	)

	var err := http_request.request(api_url, _get_headers())
	if err != OK:
		push_error("An error occurred in the HTTP request.")
		http_request.queue_free()
		leaderboard_fetch_failed.emit("Could not send request.")


func submit_leaderboard_entry(player_name: String, time_sec: int, deaths: int) -> void:
	if api_url.is_empty() or api_key.is_empty():
		push_error("API config not loaded. Check your .env file.")
		leaderboard_entry_submission_failed.emit("API config not loaded.")
		return

	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(
		func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
			_on_submit_leaderboard_entry_request_completed(http_request, result, response_code, body)
	)

	var request_body = JSON.stringify({"playerName": player_name, "data": {"time": time_sec, "deaths": deaths}})
	var err := http_request.request(api_url, _get_headers(), HTTPClient.METHOD_POST, request_body)
	if err != OK:
		push_error("An error occurred in the HTTP request.")
		http_request.queue_free()

func _on_leaderboard_request_completed(
	http_request: HTTPRequest,
	result: int,
	response_code: int,
	body: PackedByteArray
) -> void:
	http_request.queue_free()

	if result != HTTPRequest.RESULT_SUCCESS:
		leaderboard_fetch_failed.emit("Network error.")
		return

	if response_code != 200:
		leaderboard_fetch_failed.emit("Server error (code %s)." % str(response_code))
		return

	var parser := JSON.new()
	var parse_err := parser.parse(body.get_string_from_utf8())
	if parse_err != OK:
		leaderboard_fetch_failed.emit("Could not parse response.")
		return

	var parsed: Variant = parser.data
	if typeof(parsed) != TYPE_DICTIONARY:
		leaderboard_fetch_failed.emit("Unexpected response.")
		return

	var data: Dictionary = parsed
	var entries = data.get("items", [])
	if not entries is Array:
		leaderboard_fetch_failed.emit("Unexpected response.")
		return

	leaderboard_loaded.emit(entries)

func _on_submit_leaderboard_entry_request_completed(
	http_request: HTTPRequest,
	result: int,
	response_code: int,
	body: PackedByteArray
) -> void:
	http_request.queue_free()

	if result != HTTPRequest.RESULT_SUCCESS:
		leaderboard_entry_submission_failed.emit("Network error.")
		return

	if response_code == 409:
		leaderboard_entry_submission_failed.emit("Player Name already in use. Please choose another one")
		return

	if response_code != 201:
		leaderboard_entry_submission_failed.emit("Server error (code %s)." % str(response_code))
		return

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if parsed:
		leaderboard_entry_submitted_successfully.emit()
	else:
		leaderboard_entry_submission_failed.emit("Unexpected response.")
