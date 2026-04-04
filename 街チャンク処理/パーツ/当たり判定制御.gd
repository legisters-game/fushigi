extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		プロセス制御(true)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		プロセス制御(false)
		
func プロセス制御(ブール:bool)->void:
	for i:Node3D in get_children():
		if ブール:
			i.process_mode=Node.PROCESS_MODE_INHERIT
		else:
			i.process_mode=Node.PROCESS_MODE_DISABLED
