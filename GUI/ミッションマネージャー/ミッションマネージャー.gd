@icon("res://拡張リソース/アイコン/拡張ノード/UI_ミッション.png")
extends Control
class_name ミッションマネージャー

var ミッション達:Dictionary[String,Array]
@export var ミッションセルパック:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ミッション更新()
	#データロガー.ミッションオブジェクト保存(ミッションデータ.new())
	データロガー.ミッション条件フラグ保存("いるか君誤字数",データロガー.ミッション条件取得("いるか君誤字数")+1)
	await get_tree().create_timer(3).timeout

	for i:Array in ミッション達.values():
		if i[0].条件判断():
			ミッション達.erase(i[0].ミッション名)
			#get_node("VBoxContainer/HBoxContainer/Control").完了()
			if get_node("VBoxContainer/HBoxContainer").has_node(i[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i[0].ミッション名).完了()
		else:
			#get_node("VBoxContainer/HBoxContainer/Control").バー更新(データロガー.ミッション条件取得(i.条件フラグ))
			if get_node("VBoxContainer/HBoxContainer").has_node(i[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i[0].ミッション名).バー更新(データロガー.ミッション条件取得(i[0].条件フラグ))
func ミッション更新()->void:
	ミッション達=ミッション取得()

func ミッション進行度更新()->void:
	for i:Array in ミッション達.values():
		if i[0].条件判断():
			ミッション達.erase(i[0].ミッション名)
			#get_node("VBoxContainer/HBoxContainer/Control").完了()
			if get_node("VBoxContainer/HBoxContainer").has_node(i[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i[0].ミッション名).完了()
		else:
			#get_node("VBoxContainer/HBoxContainer/Control").バー更新(データロガー.ミッション条件取得(i.条件フラグ))
			if get_node("VBoxContainer/HBoxContainer").has_node(i[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i[0].ミッション名).バー更新(データロガー.ミッション条件取得(i[0].条件フラグ))

func ミッション取得()->Dictionary[String,Array]:
	var 空辞書:Dictionary[String,Array]
	if !データロガー.config.has_section("ミッションフラグ"):
		return 空辞書
	var ミッションフラグリスト:PackedStringArray=データロガー.config.get_section_keys("ミッションフラグ")
	for i:String in ミッションフラグリスト:
		空辞書.set(i,[データロガー.ミッションオブジェクト取得(i),データロガー.ミッションオブジェクト取得(i).優先度])
		if !$VBoxContainer/HBoxContainer.has_node(空辞書[i][0].ミッション名):
			var ミッションセルノード:ミッション表示セル= ミッションセルパック.instantiate()
			$VBoxContainer/HBoxContainer.add_child(ミッションセルノード,true)
			ミッションセルノード.初期化(空辞書[i][0].ミッション名,空辞書[i][0].表示用条件,空辞書[i][0].条件数)
		#get_node("VBoxContainer/HBoxContainer/Control").初期化(空辞書[i].ミッション名,空辞書[i].表示用条件,空辞書[i].条件数)
		
	return 空辞書


func キャラスケジュール取得(NPC番号:スケジュール管理クラス.NPC)->Array[NPCスケジューラ]:
	var ソート前リスト:Array
	for ミッション:Array in ミッション達.values():
		var スケジュール:NPCスケジューラ
		if ミッション[0].キャラセリフ上書きリスト and ミッション[0].キャラセリフ上書きリスト.has(NPC番号):
			スケジュール=ミッション[0].キャラセリフ上書きリスト[NPC番号]
		if スケジュール:
			ソート前リスト.append([スケジュール,ミッション[0].優先度])

	ソート前リスト.sort_custom(func(a, b): return a[1] < b[1])
	
	var 結果: Array[NPCスケジューラ] = []
	for リスト: Array in ソート前リスト:
		結果.append(リスト[0])

	return 結果
	
	
