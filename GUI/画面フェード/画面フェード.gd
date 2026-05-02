extends Control
class_name 画面フェードクラス

func フェードアウト()->void:
	get_node("AnimationPlayer").play("フェードアウト")
	
func  フェードイン()->void:
	get_node("AnimationPlayer").play("フェードイン")
