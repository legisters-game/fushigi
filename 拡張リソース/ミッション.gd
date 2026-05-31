extends Resource
class_name ミッションデータ
@export var ミッション名:String
@export var 完了後フラグ:String

@export var 条件フラグ:String
@export var 条件数:int
@export_multiline() var 表示用条件:String

func 初期化(_name: String,辞書:Dictionary) -> void:
	ミッション名 = _name
	完了後フラグ=辞書["完了後フラグ"]
	条件フラグ=辞書["条件フラグ"]
	条件数=辞書["条件数"]
	表示用条件=辞書["表示用条件"]
	データロガー.ミッション条件フラグ追加(条件フラグ)
	

# 条件をチェックし、完了処理まで自分で行う関数
func 条件判断() -> bool:
	# 1. 条件を満たしているかチェック
	if データロガー.ミッション条件取得(条件フラグ)==条件数:
		_save_completion_to_config()
		return true
	# 2. 条件を満たしていた場合の処理（コンフィグの更新）
	return false
# コンフィグファイルへの書き込みと古いフラグの消去
func _save_completion_to_config() -> void:
	# 例: GlobalFlags にある「ミッション完了フラグ」に保存
	データロガー.フラグ追加(完了後フラグ)
	
	# 進行中だった自身のミッションフラグは消去
	データロガー.ミッション条件フラグ消去(条件フラグ)
	データロガー.ミッションフラグ消去(ミッション名)
	
	# ここで実際に ConfigFile に save() する処理を呼ぶ
	データロガー.全保存()
	#print("ミッション「", mission_name, "」のデータを完了に移行し、進行中フラグを消去しました。")
