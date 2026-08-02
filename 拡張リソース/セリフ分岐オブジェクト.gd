@tool
@icon("res://拡張リソース/アイコン/セリフ分岐.png")
extends セリフオブジェクト
class_name セリフ分岐オブジェクト
@export var 選択肢:Array[String]=[]:
	set(value):
		if value.size() > 3:
			value.resize(3)
			push_warning("配列の最大サイズは3までです。")
		選択肢 = value

@export var 選択1セリフ:Array[セリフオブジェクト]
@export var 選択2セリフ:Array[セリフオブジェクト]
@export var 選択3セリフ:Array[セリフオブジェクト]
