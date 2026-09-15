extends Control
class_name 画面フェードクラス

var 消え中:bool
signal 画面消えた



func フェードイン待機(オープン:レベル制御クラス)->void:
	await オープン.読み込み完了シグナル
	フェードイン()


func フェードアウト()->void:
	get_node("AnimationPlayer").play("フェードアウト")
	消え中=true
	
func  フェードイン()->void:
	get_node("AnimationPlayer").play("フェードイン")


func _on_animation_player_animation_finished(アニメーション名: StringName) -> void:
	if アニメーション名=="フェードアウト":
		画面消えた.emit()
		消え中=false
