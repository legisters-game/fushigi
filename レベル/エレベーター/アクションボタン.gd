extends StaticBody3D
@onready var ガイドボタン:Sprite3D=$"会話ガイドボタン"

func 実行()->void:
	if not get_parent().GUI.visible:
		get_tree().get_first_node_in_group("UI").hide()
		get_parent().GUI.show()
	
func ガイド表示(する:bool)->void:
	ガイドボタン.visible=する
