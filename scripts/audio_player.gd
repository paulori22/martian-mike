extends Node
class_name GlobalAudioPlayer

enum SfxType {HURT, JUMP}

var hurt = preload("res://assets/audio/hurt.wav")
var jump = preload("res://assets/audio/jump.wav")

func play_sfx(sfx_name: SfxType):
	var stream = null
	if sfx_name == SfxType.HURT:
		stream = hurt
	elif sfx_name == SfxType.JUMP:
		stream = jump
	else:
		printerr("Invalid sfx name")
	
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	asp.name = "SFX"

	add_child(asp)
	asp.play()
	
	await asp.finished
	asp.queue_free()
