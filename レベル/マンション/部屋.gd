extends Node3D
#仮でキールを椅子に座らせる謎のスクリプト
@export var セリフ:Array[セリフオブジェクト]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$"椅子キール".実行($"エンティティ")




func _on_椅子_座られた() -> void:
	if データロガー.フラグあるか("キール出会い済"):return
	get_tree().get_first_node_in_group("全体制御").シナリオ演出実行("res://シナリオ/シナリオシーン/プロローグキール出会い/プロローグキール出会い.tscn")


func _on_リビング入る用_プレイヤー入った() -> void:
	if データロガー.ミッションフラグあるか("ここはどこ？"):
		var レベル制御:レベル制御クラス=get_tree().get_first_node_in_group("全体制御")
		var キール:NPCクラス=レベル制御.NPC制御返し().NPC取得(スケジュール管理クラス.NPC.キール)
		if キール:
			レベル制御.カメラ返し().ターゲットオーバーライド(キール.ターゲッター返し(),Vector3(0,0.22,0),1,Vector2(80,100))
			レベル制御.GUI.メッセージボックス.表示("？？？",セリフ)
			await レベル制御.GUI.メッセージボックス.会話終了
			レベル制御.カメラ返し().ターゲットオーバーライド()
	#get_tree().get_first_node_in_group("プレイヤー").
