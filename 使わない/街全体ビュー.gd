extends Node3D
class_name デバッグ用街シーン
var デバッグ:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if デバッグ:return
	queue_free()
