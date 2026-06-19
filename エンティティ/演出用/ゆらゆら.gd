@tool
extends SpringBoneSimulator3D

@export var アニメーションプレイヤー:AnimationPlayer
@export var wave_speed: float = 3.0       # 揺れの速さ（呼吸のテンポ）
@export var wave_intensity: float = 0.1   # 揺れの強さ（生存感のピクセル幅）
@export var 反転:bool
@export var 三次元:bool

var active切り替え判断用:bool=true

func _physics_process(delta: float) -> void:
	var time:float = Time.get_ticks_msec() / 1000.0
	
	# サイン波を使って、上下（Y軸）や左右（X軸）への力を常に変動させる
	var force_y:float = sin(time * wave_speed) * wave_intensity
	
	var force_x:float = cos(time * wave_speed * 0.7) * (wave_intensity * 0.5) # 少し複雑な揺れにする
	if 反転:
		force_x=-force_x
	
	# 常に変化する力を与え続けることで、強制的にボーンを往復運動（ゆらゆら）させる
	active= (アニメーションプレイヤー and not アニメーションプレイヤー.current_animation)
	if active and not active切り替え判断用:
		reset()
	active切り替え判断用=active
	#force_y=0
	#force_x=0
	if 三次元:
		var force_z:float = -cos(time * wave_speed * 0.9) * (wave_intensity * 0.7)
		#force_z=0
		external_force = Vector3(force_x, force_y, force_z)
	else:
		external_force = Vector3(force_x, force_y, 0.0)
		
