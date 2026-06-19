extends Control
class_name ミッション表示セル
@onready var ミッションラベル:Label=$"TextureRect/ミッション名"
@onready var ミッション条件ラベル:Label=$"TextureRect/ミッション名/達成条件"
@onready var バー:ProgressBar=$"進行状況"
# Called when the node enters the scene tree for the first time.


func 初期化(ミッション名:String,条件:String,条件数:int)->void:
	if !is_node_ready():
		await ready
	ミッションラベル.text=ミッション名
	ミッション条件ラベル.text=条件
	name=ミッション名
	バー.max_value=条件数
# Called every frame. 'delta' is the elapsed time since the previ

func バー更新(値:int)->void:
	$"進行状況".value=値

func 完了()->void:
	$"進行状況".value=$"進行状況".max_value
	var アニメーション:Tween=create_tween()
	アニメーション.tween_property($"完了メッセージ","scale",Vector2(1,1),0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	アニメーション.tween_property($"完了メッセージ/発光演出","scale",Vector2(3,3),0.7).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_delay(0.1)
	アニメーション.parallel().tween_property($"完了メッセージ/発光演出","self_modulate",Color(1.0, 1.0, 1.0, 1.0),0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(0.1)
	アニメーション.parallel().tween_property($"完了メッセージ","scale",Vector2(1.6,1.6),1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await アニメーション.finished
	queue_free()
