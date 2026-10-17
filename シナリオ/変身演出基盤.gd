@tool
extends 演出基盤クラス

func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		var プレイヤー:プレイヤークラス=get_tree().get_first_node_in_group("プレイヤー")
		if プレイヤー:
			global_position=プレイヤー.global_position
			global_rotation=プレイヤー.global_rotation
