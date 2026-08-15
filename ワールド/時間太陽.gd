@icon("res://拡張リソース/アイコン/拡張ノード/時間太陽.png")
extends DirectionalLight3D
class_name 時間太陽
# 0.25 0.5  0.75  1 
# 1日の長さ（現実の秒数）。300なら5分で1日。
@export var 一日の時間: float = 300.0
@export_color_no_alpha var top:Color
@export_color_no_alpha var ho:Color
@export_color_no_alpha var 夕top:Color
@export_color_no_alpha var 夕ho:Color
@export_color_no_alpha var 夜top:Color
@export_color_no_alpha var 夜ho:Color
@export_color_no_alpha var 真夜top:Color
@export_color_no_alpha var 真夜ho:Color
@export var 雲:NoiseTexture2D
var 論理日:int=0

enum 時間{真昼,夕,夜,真夜,朝}
# 現在の時間（0.0 〜 1.0 の間をループ）
var 現時間: float = 0.0
var ストップ:bool
var 時間辞書:Dictionary[int,float]={時間.真昼:0.0,時間.夕:0.24,時間.夜:0.26,時間.真夜:0.35,時間.朝:0.73}
var シグナル:Dictionary={"夜":false,"真夜":false,"朝":false,"真昼":false,"夕":false}

func _ready() -> void:
	#現時間=時間辞書[時間.真夜]
	if データロガー.システム設定読み込み("影オフ"):
		shadow_enabled=false
	while true:
		await  get_tree().create_timer(1).timeout
		#print(現時間)
	return
	夕()
	朝()

func _process(delta:float):
	if ストップ:return
	# 時間を更新
	現時間 += delta / 一日の時間
	if いつ()==時間.夜 or いつ()==時間.真夜: 現時間 += (delta / 一日の時間)*2.2
	if 現時間 > 1.0:
		現時間 = 0.0
		論理日+=1
	
	# 1. 太陽の角度を回転させる（X軸回転）
	# 現時間 0.0 = 正午 / 0.25 = 日没 / 0.5 = 真夜中 / 0.75 = 日の出
	var 角度:float = 現時間 * 360.0
	rotation_degrees.x = 角度 - 90.0 # -90度からスタートして真上を通るように調整
	#print(現時間)
	# 2. 夜は太陽の光を消す（オプション）
	if 現時間>時間辞書[時間.真昼] and 現時間<=時間辞書[時間.夕]:
		#print("真昼")
		真昼()
		
	elif 現時間>時間辞書[時間.夕] and 現時間<=時間辞書[時間.夜]:
		#print("夕")
		夕()
	elif 現時間>時間辞書[時間.夜] and 現時間<=時間辞書[時間.真夜]:
		#print("夜")
		夜()
	elif 現時間>時間辞書[時間.真夜] and 現時間<=時間辞書[時間.朝]:
		#print("迷る")
		真夜()
	elif 現時間>時間辞書[時間.朝] and 現時間<=1-0.01:
		#print("朝")
		朝()
	elif 現時間>1-0.01:
		#print("真昼")
		真昼()
	
##夜にする
func 夜()->void:
	if シグナル["夜"]:
		return
	print("夜")
	シグナル["夜"]=true
	シグナル["真夜"]=false
	var アニメ:Tween=get_tree().create_tween()
	var マテリアル:ProceduralSkyMaterial=get_world_3d().environment.sky.sky_material
	アニメ.tween_property(get_world_3d().environment,"background_energy_multiplier",2,5.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_top_color",夜top,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	#アニメ.tween_property(マテリアル,"energy_multiplier",0.2,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_top_color",夜top,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_horizon_color",夜ho,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	#マテリアル.energy_multiplier=0.14

##真夜にする
func 真夜()->void:
	if シグナル["真夜"]:
		return
	print("真夜")
	シグナル["真夜"]=true
	シグナル["朝"]=false
	var アニメ:Tween=get_tree().create_tween()
	var マテリアル:ProceduralSkyMaterial=get_world_3d().environment.sky.sky_material
	アニメ.tween_property(self,"light_energy",0,5.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(get_world_3d().environment,"background_energy_multiplier",2.2,5.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_top_color",真夜top,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_horizon_color",真夜ho,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_cover_modulate",Color(1.0, 1.0, 1.0, 1.0),3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

##朝にする
func 朝()->void:
	if シグナル["朝"]:
		return
	print("朝")
	シグナル["朝"]=true
	シグナル["真昼"]=false
	var アニメ:Tween=get_tree().create_tween()
	var マテリアル:ProceduralSkyMaterial=get_world_3d().environment.sky.sky_material
	アニメ.tween_property(self,"light_energy",1.7,5.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.tween_property(get_world_3d().environment,"background_energy_multiplier",1,5.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_top_color",top,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_horizon_color",ho,3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	アニメ.parallel().tween_property(マテリアル,"sky_cover_modulate",Color(1.0, 1.0, 1.0, 0),3.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

##真昼にする
func 真昼()->void:
	if シグナル["真昼"]:
		return
	print("真昼")
	シグナル["真昼"]=true
	シグナル["夕"]=false
	var アニメ:Tween=get_tree().create_tween()
	#var マテリアル:ProceduralSkyMaterial=get_world_3d().environment.sky.sky_material
	アニメ.tween_property(self,"light_energy",1.8,5.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
##夕方にする
func 夕()->void:
	if シグナル["夕"]:
		return
	print("夕")
	シグナル["夕"]=true
	シグナル["夜"]=false
	var アニメ:Tween=get_tree().create_tween()
	var マテリアル:ProceduralSkyMaterial=get_world_3d().environment.sky.sky_material
	アニメ.tween_property(self,"light_energy",1,5.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	アニメ.parallel().tween_property(マテリアル,"sky_top_color",夕top,1)
	アニメ.parallel().tween_property(マテリアル,"sky_horizon_color",夕ho,1)

##今がいつかを返す
func いつ()->時間:
	if 現時間>時間辞書[時間.真昼] and 現時間<=時間辞書[時間.夕]:
		#print("真昼")
		return 時間.真昼
		
	elif 現時間>時間辞書[時間.夕] and 現時間<=時間辞書[時間.夜]:
		#print("夕")
		return 時間.夕
	elif 現時間>時間辞書[時間.夜] and 現時間<=時間辞書[時間.真夜]:
		#print("夜")
		return 時間.夜
	elif 現時間>時間辞書[時間.真夜] and 現時間<=時間辞書[時間.朝]:
		#print("迷る")
		return 時間.真夜
	elif 現時間>時間辞書[時間.朝] and 現時間<=1-0.01:
		#print("朝")
		return 時間.朝
	elif 現時間>1-0.01:
		#print("真昼")
		return 時間.真昼
	else:
		return 時間.真昼

##今日の日付を返す
func 日付()->int:
	if 現時間>時間辞書[時間.朝]:
		return 論理日+1
	return 論理日


func _on_timer_timeout() -> void:
	print(日付())
