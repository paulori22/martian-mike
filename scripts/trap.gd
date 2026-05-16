extends Node2D

enum AnimationType { VERTICAL, HORIZONTAL}

@export var animation_option: AnimationType = AnimationType.HORIZONTAL
@export var delay_animation: float = 0

signal touched_player

func _ready() -> void:
	play_selected_animation()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		touched_player.emit()

func play_selected_animation():
	await get_tree().create_timer(delay_animation).timeout
	if animation_option == AnimationType.HORIZONTAL:
		$AnimationPlayer.play("move")
	if animation_option == AnimationType.VERTICAL:
		$AnimationPlayer.play("move_vertical")
