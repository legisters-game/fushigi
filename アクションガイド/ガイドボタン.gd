@icon("res://拡張リソース/アイコン/セリフ.png")
extends Sprite3D
@export var アクション:InputEventAction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	var アクセス辞書鍵:String
	if アクション:
		var 入力キー:InputEvent
		for i:InputEvent in InputMap.action_get_events(アクション.action):
			入力キー=i
			break
		if not 入力キー:return
		アクセス辞書鍵=キーマッピング.インプットイベントから入力イベントを文字で返す(入力キー)
	if キーマッピング.キー文字.has(アクセス辞書鍵):
		get_node("Label3D").text=キーマッピング.キー文字[アクセス辞書鍵]
