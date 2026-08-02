@icon("res://拡張リソース/アイコン/拡張ノード/レベル制御.png")
extends Node3D
class_name レベル制御クラス
var 都市プレイヤー座標:Vector3
#var 全体都市:Node3D
var ディメンション:String
var レベルルート:レベル基礎クラス
var ディメンション階層:int

var 読み込み中チャンク:Array[String]
var 読み込みチャンクシグナル有効:bool

signal 読み込み完了シグナル
signal レベル読み込み完了シグナル
@export  var 実験:ミッションデータ
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(1).timeout
	データロガー.ミッションフラグ追加(実験)
	データロガー.全保存()
	
	
	ディメンション=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.ディメンション,"オープンワールド")
	ディメンション階層=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.ディメンション階層,0)
	
	if ディメンション!="オープンワールド":
		レベル移動(ディメンション,0,ディメンション階層,true)
		
		
		await レベル読み込み完了シグナル
		get_tree().get_first_node_in_group("プレイヤー").プレイヤーロード()
	else:
		get_tree().get_first_node_in_group("プレイヤー").global_position=データロガー.プレイヤーステート取得(データロガー.プレイヤーデータ.座標,Vector3.ZERO)
		#await get_tree().create_timer(0.1).timeout
		読み込みチャンクシグナル送信スタート()
		get_node("Control/画面フェード").フェードイン待機(self)
		await 読み込み完了シグナル
		get_tree().get_first_node_in_group("プレイヤー").プレイヤーロード()
		get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=false
	
	await  get_tree().create_timer(2).timeout
	if !データロガー.フラグあるか("最初の演出完了"):
		シナリオ演出実行("res://シナリオ/シナリオシーン/プロローグ1目覚め/プロローグ1目覚め.tscn")
	
	while true:
		await get_tree().create_timer(50).timeout
		データロガー.全保存()

func レベル移動(レベル:String, 番号:int=0,階層:int=0,フェードアウトオフ:bool=false)->void:
	#シーンの演出
	get_tree().get_first_node_in_group("プレイヤー").レベル移動中=true
	get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=true
	get_tree().get_first_node_in_group("プレイヤー").move_direction=Vector3.ZERO
	if not フェードアウトオフ:
		get_node("Control/画面フェード").フェードアウト()
	都市プレイヤー座標=get_tree().get_first_node_in_group("プレイヤー").global_position
	await get_tree().create_timer(1).timeout
	get_tree().get_first_node_in_group("プレイヤー").簡易移動停止()
	var レベルシーン:PackedScene=load(レベル)
	レベルルート=レベルシーン.instantiate()
	for i:Node in get_node("レベル").get_children():
		i.queue_free()
	get_node("レベル").add_child(レベルルート)
	レベルルート=レベルルート
	レベルルート.階層有効(階層)
	#エレベーターの場合
	if レベルルート is エレベーターレベルクラス:
		レベルルート.初期化(番号)
		番号=0
		データロガー.ディメンションセーブロック=true
	else:
		データロガー.ディメンションセーブロック=false
	
	if has_node("都市3d仮"):
		var 全体都市=get_node("都市3d仮")
		remove_child(全体都市)
	単純ワープ(レベルルート.テレポート先[番号])
	レベル読み込み完了シグナル.emit()
	ディメンション=レベル
	ディメンション階層=階層
	get_tree().get_first_node_in_group("プレイヤー").プレイヤーセーブ()
	データロガー.全保存()
	get_node("Control/画面フェード").フェードイン()
	await get_tree().create_timer(2).timeout
	get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=false
	get_tree().get_first_node_in_group("プレイヤー").操作ロック前位置=get_tree().get_first_node_in_group("プレイヤー").global_position
	get_tree().get_first_node_in_group("プレイヤー").レベル移動中=false
	
func 単純ワープ(ワープ先マーカー:Marker3D,フェードアウト:bool=false)->void:
	if フェードアウト:
		get_node("Control/画面フェード").フェードアウト()
		get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=true
		await get_tree().create_timer(1).timeout
		
	get_tree().get_first_node_in_group("プレイヤー").global_position=ワープ先マーカー.global_position
	get_tree().get_first_node_in_group("プレイヤー").簡易移動停止()
	if フェードアウト:
		get_node("Control/画面フェード").フェードイン()
		await get_tree().create_timer(1).timeout
		get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=false


func 都市戻り(プレイヤー座標マーカー:Marker3D=null)->void:
	get_tree().get_first_node_in_group("プレイヤー").レベル移動中=true
	get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=true
	get_tree().get_first_node_in_group("プレイヤー").move_direction=Vector3.ZERO
	get_node("Control/画面フェード").フェードアウト()
	await get_tree().create_timer(1).timeout
	get_tree().get_first_node_in_group("プレイヤー").簡易移動停止()
	if プレイヤー座標マーカー:
		都市プレイヤー座標=プレイヤー座標マーカー.global_position
	for i in get_node("レベル").get_children():
		i.queue_free()
	var 街シーン:PackedScene=load("res://街チャンク処理/都市3d仮.tscn")
	
	add_child(街シーン.instantiate())
	get_tree().get_first_node_in_group("プレイヤー").global_position=都市プレイヤー座標
	ディメンション="オープンワールド"
	get_tree().get_first_node_in_group("プレイヤー").プレイヤーセーブ()
	データロガー.全保存()
	読み込みチャンクシグナル送信スタート()
	get_node("Control/画面フェード").フェードイン待機(self)
	await get_tree().create_timer(0.1).timeout
	get_tree().get_first_node_in_group("プレイヤー").global_position=都市プレイヤー座標
	await get_tree().create_timer(1.8).timeout
	get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=false
	get_tree().get_first_node_in_group("プレイヤー").レベル移動中=false

	

func ディメンション返し()->String:
	return ディメンション

func ディメンション階層返し()->int:
	return ディメンション階層

	
func 読み込みチャンクシグナル送信スタート()->void:
	読み込み中チャンク=[]
	読み込みチャンクシグナル有効=true



func 読み込み追加(チャンク:String)->void:
	if 読み込み中チャンク.has(チャンク) or not 読み込みチャンクシグナル有効:
		return
	読み込み中チャンク.append(チャンク)
	#await get_tree().create_timer(1).timeout
	#読み込み完了(チャンク)

func 読み込み完了(チャンク:String)->void:
	if 読み込み中チャンク.has(チャンク) and 読み込みチャンクシグナル有効:
		読み込み中チャンク.erase(チャンク)
		if 読み込み中チャンク.is_empty():
			読み込み完了シグナル.emit()

func シナリオ演出実行(演出パス: String):
	var 演出リソース: = load(演出パス)
	if not 演出リソース:
		return
	
	var 演出インスタンス:Node = 演出リソース.instantiate()
	
	# 型チェック（演出基盤クラスを継承しているか）
	if 演出インスタンス is 演出基盤クラス:
		get_tree().get_first_node_in_group("UI").get_node("画面フェード").フェードアウト()
		
		if has_node("都市3d仮"):
			演出インスタンス.都市ルート=get_node("都市3d仮")
			
		# プレイヤーを止める（Regiさんのプレイヤーノードに合わせて調整）
		get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=true
		get_tree().get_first_node_in_group("プレイヤー").move_direction=Vector3.ZERO
		

		get_node("演出ルート").add_child(演出インスタンス)
			
		# 演出完了時の後処理を接続
		演出インスタンス.演出完了通知.connect(_演出終了後の後処理.bind(演出インスタンス))
		
		
		if has_node("都市3d仮") and not 演出インスタンス.表示リスト.is_empty():
			#await get_tree().create_timer(0.1).timeout
			#await get_tree().process_frame
			#await get_tree().process_frame
			#await get_tree().process_frame
			if not 読み込み中チャンク.is_empty():
				get_tree().get_first_node_in_group("UI").get_node("画面フェード").フェードイン待機(self)
				await 読み込み完了シグナル
		elif has_node("都市3d仮") and 演出インスタンス.表示リスト.is_empty():
			await get_tree().create_timer(1).timeout
			get_tree().get_first_node_in_group("UI").get_node("画面フェード").フェードイン()
		else:
			await get_tree().create_timer(1.2).timeout
			get_tree().get_first_node_in_group("UI").get_node("画面フェード").フェードイン()
		# 実行！
		#await get_tree().create_timer(0.1).timeout
		get_tree().get_first_node_in_group("UI").ムービー中非表示()
		get_node("NPC制御").hide()
		get_tree().get_first_node_in_group("プレイヤー").hide()
		演出インスタンス.演出開始()

func _演出終了後の後処理(インスタンス: 演出基盤クラス):
	get_tree().get_first_node_in_group("プレイヤー").移動操作ロック=false
	インスタンス.queue_free()
	get_node("NPC制御").show()
	get_tree().get_first_node_in_group("プレイヤー").show()
	get_tree().get_first_node_in_group("UI").ムービー終了表示()
	if インスタンス.再生後発生ミッション and !インスタンス.再生後発生ミッション.is_empty():
		for i:ミッションデータ in インスタンス.再生後発生ミッション:
			データロガー.ミッションフラグ追加(i)
			
		get_tree().get_first_node_in_group("UI").get_node("ミッションマネージャー").ミッション更新()
	# プレイヤーのカメラをメインに戻す処理などをここに書く
