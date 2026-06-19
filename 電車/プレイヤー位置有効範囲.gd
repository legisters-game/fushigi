extends Area3D
@export var RemoteTransform:RemoteTransform3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not RemoteTransform:queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is プレイヤークラス:
		var 前位置:Vector3=body.global_position
		RemoteTransform.remote_path=body.get_parent().get_path()
		print(body.get_parent().get_path())
		body.global_position=前位置
		データロガー.フラグ追加("電車乗車")
		RemoteTransform.force_update_cache()
		body.global_position=前位置


func _on_body_exited(body: Node3D) -> void:
	if body is プレイヤークラス:
		RemoteTransform.remote_path=NodePath("")
		RemoteTransform.force_update_cache()
		データロガー.フラグ消去("電車乗車")
