extends Node3D
@onready var animation_player: AnimationPlayer = $"Black male intro animation/AnimationPlayer"
@onready var button: Button = $CanvasLayer/Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer.hide()
	animation_player.play("bomb falling/Intro_2")
	await animation_player.animation_finished
	$CanvasLayer.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	animation_player.play("bomb falling/Intro_2")
	button.hide()
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Test.tscn")
