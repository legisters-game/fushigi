@icon("res://拡張リソース/アイコン/拡張ノード/UI_ミッション.png")
extends Control
class_name ミッションマネージャー

var ミッション達:Dictionary[String,Array]
@export var ミッションセルパック:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ミッション更新()
	#データロガー.ミッションオブジェクト保存(ミッションデータ.new())
	#仮のミッション追加
	データロガー.ミッション条件フラグ保存("いるか君誤字数",データロガー.ミッション条件取得("いるか君誤字数")+1)
	await get_tree().create_timer(3).timeout

	for ミッションと優先度:Array in ミッション達.values():
		if ミッションと優先度[0].条件判断():
			ミッション達.erase(ミッションと優先度[0].ミッション名)
			#get_node("VBoxContainer/HBoxContainer/Control").完了()
			if get_node("VBoxContainer/HBoxContainer").has_node(ミッションと優先度[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(ミッションと優先度[0].ミッション名).完了()
		else:
			#get_node("VBoxContainer/HBoxContainer/Control").バー更新(データロガー.ミッション条件取得(i.条件フラグ))
			if get_node("VBoxContainer/HBoxContainer").has_node(ミッションと優先度[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(ミッションと優先度[0].ミッション名).バー更新(データロガー.ミッション条件取得(ミッションと優先度[0].条件フラグ))
func ミッション更新()->void:
	ミッション達=ミッション取得()

func ミッション進行度更新()->void:
	for ミッションと優先度:Array in ミッション達.values():
		if ミッションと優先度[0].条件判断():
			ミッション達.erase(ミッションと優先度[0].ミッション名)
			#get_node("VBoxContainer/HBoxContainer/Control").完了()
			if get_node("VBoxContainer/HBoxContainer").has_node(ミッションと優先度[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(ミッションと優先度[0].ミッション名).完了()
		else:
			#get_node("VBoxContainer/HBoxContainer/Control").バー更新(データロガー.ミッション条件取得(i.条件フラグ))
			if get_node("VBoxContainer/HBoxContainer").has_node(ミッションと優先度[0].ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(ミッションと優先度[0].ミッション名).バー更新(データロガー.ミッション条件取得(ミッションと優先度[0].条件フラグ))

func ミッション取得() -> Dictionary[String, Array]:
	var 結果辞書: Dictionary[String, Array] = {}
	if !データロガー.config.has_section("ミッションフラグ"):
		return 結果辞書

	var ミッションフラグリスト: PackedStringArray = データロガー.config.get_section_keys("ミッションフラグ")
	var メインリスト: Array = []
	var サブリスト: Array = []

	# 1. データの取得とメイン／サブの振り分け
	for フラグ: String in ミッションフラグリスト:
		var オブジェクト:ミッションデータ = データロガー.ミッションオブジェクト取得(フラグ)
		var 要素: Array = [オブジェクト, オブジェクト.優先度]
		結果辞書[フラグ] = 要素

		if オブジェクト.サブ:
			サブリスト.append(要素)
		else:
			メインリスト.append(要素)

	# 2. 優先度の高い順（降順）にそれぞれソート
	メインリスト.sort_custom(func(a:Array, b:Array): return a[1] > b[1])
	サブリスト.sort_custom(func(a:Array, b:Array): return a[1] > b[1])

	# 3. メインの後にサブを結合
	var ソート済み全リスト: Array = メインリスト + サブリスト

	# 4. GUI上の表示順（ノード順）をソート結果に合わせて生成・移動
	var コンテナ:VBoxContainer = $VBoxContainer/HBoxContainer
	for インデックス:int in range(ソート済み全リスト.size()):
		var ミッション:ミッションデータ = ソート済み全リスト[インデックス][0]
		var ノード名: String = ミッション.ミッション名
		var セルノード: ミッション表示セル

		if not コンテナ.has_node(ノード名):
			セルノード = ミッションセルパック.instantiate()
			セルノード.name = ノード名
			コンテナ.add_child(セルノード, true)
			セルノード.初期化(ミッション.ミッション名, ミッション.表示用条件, ミッション.条件数)
		else:
			セルノード = コンテナ.get_node(ノード名) as ミッション表示セル

		# コンテナ内の表示順序をソート結果のインデックスに合わせる
		コンテナ.move_child(セルノード, インデックス)

	return 結果辞書


func キャラスケジュール取得(NPC番号:スケジュール管理クラス.NPC)->Array[NPCスケジューラ]:
	var ソート前リスト:Array
	for ミッション:Array in ミッション達.values():
		var スケジュール:NPCスケジューラ
		if ミッション[0].キャラセリフ上書きリスト and ミッション[0].キャラセリフ上書きリスト.has(NPC番号):
			スケジュール=ミッション[0].キャラセリフ上書きリスト[NPC番号]
		if スケジュール:
			ソート前リスト.append([スケジュール,ミッション[0].優先度])

	ソート前リスト.sort_custom(func(a:Array, b:Array): return a[1] < b[1])
	
	var 結果: Array[NPCスケジューラ] = []
	for リスト: Array in ソート前リスト:
		結果.append(リスト[0])

	return 結果
	
	
