extends Node

const SAVE_PATH = "user://save_game.cfg"
var config = ConfigFile.new()
var ディメンションセーブロック:bool=false
# 【ステータスの定義】
# これにより、DataManager.P_HP のように数値（int）として扱える
enum プレイヤーデータ {
	体力,
	最大体力,
	攻撃力,
	防御力,
	ディメンション,
	ディメンション階層,
	座標,
	回転座標,
}

func _ready():
	if config.load(SAVE_PATH)!=OK:
		print("えらーー")
		全保存()
	
	フラグ追加("初期")

func _exit_tree() -> void:
	全保存()


# --- フラグ管理 (文字列があるかないか) ---
func フラグ追加(フラグ名: String):
	config.set_value("フラグ", フラグ名, true)
	#config.save(SAVE_PATH)

func フラグ消去(フラグ名: String):
	config.erase_section_key("フラグ", フラグ名)

func フラグあるか(フラグ名: String) -> bool:
	return config.has_section_key("フラグ", フラグ名)

# --- ステータス管理 (Enumをそのままintキーとして保存) ---
# 文字列の辞書を介さず、Enum(int) を直接 ConfigFile に書き込む
func プレイヤーステート保存(stat_type: プレイヤーデータ, value: Variant)->void:
	# config内部では "0", "1" といったキーで保存されるが
	# 外側からは Enum の名前でアクセスしている状態になる
	if ディメンションセーブロック:return
	config.set_value("プレイヤー", str(stat_type), value)

func プレイヤーステート取得(stat_type: プレイヤーデータ, default_value: Variant = 0) -> Variant:
	return config.get_value("プレイヤー", str(stat_type), default_value)


func ミッションオブジェクト取得(ミッション用フラグ名:String)->ミッションデータ:
	var 辞書:Dictionary
	辞書["完了後フラグ"]=""
	辞書["条件フラグ"]=""
	辞書["条件数"]=0
	辞書["表示用条件"]=""
	if config.get_value("ミッションフラグ", ミッション用フラグ名,null):
		辞書=config.get_value("ミッションフラグ", ミッション用フラグ名,null)
		
	#オブジェクトで返す
	var オブジェクト:ミッションデータ=ミッションデータ.new()
	オブジェクト.初期化(ミッション用フラグ名,辞書)
	return オブジェクト

func ミッションフラグ追加(ミッションオブジェクト:ミッションデータ)->void:
	if config.has_section("ミッションフラグ")and config.has_section_key("ミッションフラグ",ミッションオブジェクト.ミッション名):
		print("すでに追加済み")
		return
	var 辞書:Dictionary

	辞書.set("完了後フラグ",ミッションオブジェクト.完了後フラグ)
	辞書.set("条件フラグ",ミッションオブジェクト.条件フラグ)
	辞書.set("条件数",ミッションオブジェクト.条件数)
	辞書.set("表示用条件",ミッションオブジェクト.表示用条件)
	if ミッションオブジェクト.キャラセリフ上書きリスト!=null and ミッションオブジェクト.キャラセリフ上書きリスト.size()>=1:
		辞書.set("スケジュール",ミッションオブジェクト.キャラセリフ上書きリスト)
	#ミッションオブジェクト.
	config.set_value("ミッションフラグ",ミッションオブジェクト.ミッション名,辞書)
	if get_tree().get_first_node_in_group("UI"):
		get_tree().get_first_node_in_group("UI").get_node("ミッションマネージャー").ミッション取得()
	else:
		print("ミッションをスクリプトで更新失敗")
	
func ミッションフラグ消去(ミッション用フラグ名:String)->void:
	config.erase_section_key("ミッションフラグ", ミッション用フラグ名)
	
func ミッション条件取得(ミッション条件フラグ:String)->int:
	return config.get_value("ミッション条件フラグ", ミッション条件フラグ, 0)

func ミッション条件フラグ保存(ミッション条件フラグ:String,値:int)->void:
	#なんだこれ
	if config.has_section_key("ミッション条件フラグ",ミッション条件フラグ):
		config.set_value("ミッション条件フラグ",ミッション条件フラグ, 値)
		get_tree().get_first_node_in_group("UI").get_node("ミッションマネージャー").ミッション進行度更新()

func ミッション条件フラグ追加(ミッション条件フラグ:String)->void:
	if !config.has_section_key("ミッション条件フラグ",ミッション条件フラグ):
		config.set_value("ミッション条件フラグ",ミッション条件フラグ, 0)

func ミッション条件フラグ消去(ミッション条件フラグ:String)->void:
	config.erase_section_key("ミッション条件フラグ", ミッション条件フラグ)
	


	
# セーブ実行
func 全保存():
	config.save(SAVE_PATH)
