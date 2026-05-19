extends Node2D

@export var next_level: PackedScene = null
@export var is_final_level: bool = false

@onready var start = $Start
@onready var exit = $Exit
@onready var death_zone = $DeathZone

var player: Player = null

@onready var hud = $UILayer/HUD
@onready var ui_layer = $UILayer
@export var level_time = 5
var timer_node = null
var time_left

var win: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.global_position = start.get_spawn_position()
	var traps = get_tree().get_nodes_in_group("traps")
	for trap in traps:
		#trap.connect("touched_player", _on_trap_touched_player)
		#godot4
		trap.touched_player.connect(_on_trap_touched_player)
	
	exit.body_entered.connect(_on_exit_body_entered)
	death_zone.body_entered.connect(_on_death_zone_body_entered)
	
	time_left = level_time
	update_hud_data()

	var timer_node: Timer = Timer.new()
	timer_node.name = "Level Timer"
	timer_node.wait_time = 1
	timer_node.timeout.connect(_on_level_timer_timeout)
	add_child(timer_node)
	timer_node.start()

func _on_level_timer_timeout():
	if !win:
		time_left -= 1
		PlayerData.increase_played_time(1)
		update_hud_data()
		if time_left < 0:
			player_died()
			time_left = level_time
			hud.set_time_label(time_left)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	update_death_zone_position_based_on_player()

func update_death_zone_position_based_on_player():
	death_zone.global_position.x = player.global_position.x

func _on_death_zone_body_entered(body: Node2D) -> void:
	player_died()

func _on_trap_touched_player() -> void:
	player_died()

func reset_player():
	player.velocity = Vector2.ZERO
	player.global_position = start.get_spawn_position()

func _on_exit_body_entered(body):
	if body is Player: 
		if is_final_level || next_level != null:
			win = true
			exit.animate()
			player.active = false
			await get_tree().create_timer(1.5).timeout
			if is_final_level:
				ui_layer.show_win_screen()
			else:
				get_tree().change_scene_to_packed(next_level)

func player_died():
	AudioPlayer.play_sfx(GlobalAudioPlayer.SfxType.HURT)
	PlayerData.register_death()
	hud.set_deaths_label(PlayerData.get_deaths())
	reset_player()

func update_hud_data():
	hud.set_time_label(time_left)
	hud.set_total_time_label(PlayerData.get_played_time())
	hud.set_deaths_label(PlayerData.get_deaths())
