extends Control

func set_time_label(time:int):
	$TimeLabel.text = "TIME: " + str(time)

func set_deaths_label(deaths:int):
	$DeathsLabel.text = "DEATHS: " + str(deaths)

func set_total_time_label(total_time:int):
	$TotalTimeLabel.text = "TOTAL: " + str(total_time)
