extends StaticBody3D
class_name 街レベルゲート

@export var アクセスマーカー:Marker3D
func ガイド表示(オン:bool)->void:
	if オン:
		get_node("会話ガイドボタン").show()
	else:
		get_node("会話ガイドボタン").hide()
