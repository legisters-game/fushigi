extends Node3D
#仮でキールを椅子に座らせる謎のスクリプト

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$"椅子キール".実行($"エンティティ")




func _on_椅子_座られた() -> void:
	if データロガー.フラグあるか("キール出会い済"):return
	get_tree().get_first_node_in_group("全体制御").シナリオ演出実行("res://シナリオ/シナリオシーン/プロローグキール出会い/プロローグキール出会い.tscn")


func _on_リビング入る用_プレイヤー入った() -> void:
	if データロガー.フラグあるか("キール出会い済"):return
	pass
	#get_tree().get_first_node_in_group("プレイヤー").
