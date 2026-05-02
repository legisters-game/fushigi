extends TextureButton
class_name 選択肢ボタンクラス

@export var ラベル:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func 出現(選択肢:String)->void:
	get_node("選択肢").text=選択肢
	show()
	if name=="選択肢ボタン1":
		grab_focus()

func 入力キー指定(キー:String)->void:
	get_node("キー原点/キー").text=キー
