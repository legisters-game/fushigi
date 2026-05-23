@tool
extends Node3D
class_name 電車_前ドア
signal 開いた
signal 閉まった
@onready var アニメ:AnimationPlayer=$AnimationPlayer
# Called when the node enters the scene tree for the first time.

func 開く()->void:
	アニメ.play("開")

func 閉まる()->void:
	アニメ.play("閉")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match  anim_name:
		"開":
			開いた.emit()
		"閉":
			閉まった.emit()
