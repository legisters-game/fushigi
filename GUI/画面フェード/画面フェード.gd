extends Control
class_name 画面フェードクラス





func フェードイン待機(オープン:レベル制御クラス)->void:
	await オープン.読み込み完了シグナル
	get_node("AnimationPlayer").play("フェードイン")


func フェードアウト()->void:
	get_node("AnimationPlayer").play("フェードアウト")
	
func  フェードイン()->void:
	get_node("AnimationPlayer").play("フェードイン")
