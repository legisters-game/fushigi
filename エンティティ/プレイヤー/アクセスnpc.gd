extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is NPCクラス:
		if body.アクションポイント:
			body.アクションポイント.show()
	elif body is レベルゲート:
		body.ガイド表示(true)
	elif body is 街レベルゲート:
		body.ガイド表示(true)
	else:
		if body.has_method("ガイド表示"):
			body.ガイド表示(true)

func _on_body_exited(body: Node3D) -> void:
	if body is NPCクラス:
		if body.アクションポイント:
			body.アクションポイント.hide()
	elif body is レベルゲート:
		body.ガイド表示(false)
	elif body is 街レベルゲート:
		body.ガイド表示(false)
	else:
		if body.has_method("ガイド表示"):
			body.ガイド表示(false)
