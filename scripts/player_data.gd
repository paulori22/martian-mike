extends Node

var deaths: int = 0
var played_time: float = 0

func register_death():
	deaths += 1

func get_deaths() -> int:
	return deaths

func increase_played_time(ammount:float):
	played_time += ammount

func get_played_time()-> float:
	return played_time

func get_formatted_played_time() -> String:
	var total_seconds: int = int(played_time)
	
	var hours: int = total_seconds / 3600
	var minutes: int = (total_seconds % 3600) / 60
	var seconds: int = total_seconds % 60
	
	# Formats integers to always have 2 digits (adds leading zeros if needed)
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func reset_player_data():
	deaths = 0
	played_time = 0
