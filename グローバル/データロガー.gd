extends Node

const SAVE_PATH = "user://save_game.cfg"
var config = ConfigFile.new()

# 【ステータスの定義】
# これにより、DataManager.P_HP のように数値（int）として扱える
enum プレイヤーデータ {
	体力,
	最大体力,
	攻撃力,
	防御力,
	ディメンション,
	座標,
	回転座標
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
	config.save(SAVE_PATH)

func フラグあるか(フラグ名: String) -> bool:
	return config.has_section_key("フラグ", フラグ名)

# --- ステータス管理 (Enumをそのままintキーとして保存) ---
# 文字列の辞書を介さず、Enum(int) を直接 ConfigFile に書き込む
func プレイヤーステート保存(stat_type: プレイヤーデータ, value: Variant)->void:
	# config内部では "0", "1" といったキーで保存されるが
	# 外側からは Enum の名前でアクセスしている状態になる
	config.set_value("プレイヤー", str(stat_type), value)

func プレイヤーステート取得(stat_type: プレイヤーデータ, default_value: Variant = 0) -> Variant:
	return config.get_value("プレイヤー", str(stat_type), default_value)

# セーブ実行
func 全保存():
	config.save(SAVE_PATH)
