extends TextureProgressBar
class_name スキップバー
signal 発火
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value_changed.connect(値変化シグナル受信)
	value=0
	hide()

func 値変化シグナル受信(値:float)->void:
	if 値==100:
		発火.emit()
