@tool
extends "res://エンティティ/プレイヤー/model/モデル.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent()is Node3D:
		#print(get_parent())
		$"R-G MC Rig MoCap v1_0".owner=null
	super()
