extends BoneAttachment3D


func _ready() -> void:
	var 仮ターゲット=get_parent().get_parent().get_parent()
	var モデル:演出モデルクラス
	if 仮ターゲット is 演出モデルクラス:
		モデル=仮ターゲット
		
	if モデル:
		モデル.引き継ぎ_追従.append(self)
