extends Control
class_name ミッションマネージャー

var ミッション達:Dictionary[String,ミッションデータ]
@export var ミッションセルパック:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ミッション更新()
	#データロガー.ミッションオブジェクト保存(ミッションデータ.new())
	データロガー.ミッション条件フラグ保存("いるか君誤字数",データロガー.ミッション条件取得("いるか君誤字数")+1)
	await get_tree().create_timer(3).timeout
	for i:ミッションデータ in ミッション達.values():
		if i.条件判断():
			ミッション達.erase(i.ミッション名)
			#get_node("VBoxContainer/HBoxContainer/Control").完了()
			if get_node("VBoxContainer/HBoxContainer").has_node(i.ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i.ミッション名).完了()
		else:
			#get_node("VBoxContainer/HBoxContainer/Control").バー更新(データロガー.ミッション条件取得(i.条件フラグ))
			if get_node("VBoxContainer/HBoxContainer").has_node(i.ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i.ミッション名).バー更新(データロガー.ミッション条件取得(i.条件フラグ))
func ミッション更新()->void:
	ミッション達=ミッション取得()

func ミッション進行度更新()->void:
	for i:ミッションデータ in ミッション達.values():
		if i.条件判断():
			ミッション達.erase(i.ミッション名)
			#get_node("VBoxContainer/HBoxContainer/Control").完了()
			if get_node("VBoxContainer/HBoxContainer").has_node(i.ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i.ミッション名).完了()
		else:
			#get_node("VBoxContainer/HBoxContainer/Control").バー更新(データロガー.ミッション条件取得(i.条件フラグ))
			if get_node("VBoxContainer/HBoxContainer").has_node(i.ミッション名):
				get_node("VBoxContainer/HBoxContainer").get_node(i.ミッション名).バー更新(データロガー.ミッション条件取得(i.条件フラグ))

func ミッション取得()->Dictionary[String,ミッションデータ]:
	var 空辞書:Dictionary[String,ミッションデータ]
	if !データロガー.config.has_section("ミッションフラグ"):
		return 空辞書
	var ミッションフラグリスト:PackedStringArray=データロガー.config.get_section_keys("ミッションフラグ")
	for i:String in ミッションフラグリスト:
		空辞書.set(i,データロガー.ミッションオブジェクト取得(i))
		if !$VBoxContainer/HBoxContainer.has_node(空辞書[i].ミッション名):
			var ミッションセルノード:ミッション表示セル= ミッションセルパック.instantiate()
			$VBoxContainer/HBoxContainer.add_child(ミッションセルノード,true)
			ミッションセルノード.初期化(空辞書[i].ミッション名,空辞書[i].表示用条件,空辞書[i].条件数)
		#get_node("VBoxContainer/HBoxContainer/Control").初期化(空辞書[i].ミッション名,空辞書[i].表示用条件,空辞書[i].条件数)
		
	return 空辞書
