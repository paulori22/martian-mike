extends CanvasLayer

func show_win_screen():
	$WinScreen.update_session_stats()
	$WinScreen.visible = true

func hide_win_screen():
	$WinScreen.visible = false
