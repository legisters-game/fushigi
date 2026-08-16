@icon("res://拡張リソース/アイコン/拡張ノード/UI.png")
extends Control
@export var ムービー中非表示リスト:Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func ムービー中非表示()->void:
	for i:Control in ムービー中非表示リスト:
		if i:i.hide()

func ムービー終了表示()->void:
	for i:Control in ムービー中非表示リスト:
		if i:i.show()
