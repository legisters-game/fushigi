extends StaticBody3D
class_name ミッション進行するやつ
@export var 条件フラグ:String



func プラスいち()->void:
	データロガー.ミッション条件フラグ保存(条件フラグ,データロガー.ミッション条件取得(条件フラグ)+1)
