extends OmniLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#全てのライトに対してなんらかの共通設定を反映させたい
	process_mode=Node.PROCESS_MODE_DISABLED
