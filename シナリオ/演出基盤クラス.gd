@tool
extends Node3D

class_name 演出基盤クラス

# 演出が終わったことを親シーンに知らせるためのシグナル
signal 演出完了通知()
@export_tool_button("街表示")var 調整用=調整用街表示.bind(false)
@export_file("*.tscn") var 表示チャンク:Array[String]
@export var セリフ集: Array[セリフオブジェクト]
@export var  削除対象:Array[Node]
@export var 再生前条件更新フラグ名:String
@export var 再生前条件フラグ加算数:int
@export var 条件フラグ加算から上書き:bool


@export var 再生後フラグ:String
@export var 再生後発生ミッション:Array[ミッションデータ]
@export var プレイヤー再生前ワープ:bool
@export var プレイヤー再生後ワープ:bool

@onready var アニメーション: AnimationPlayer = $AnimationPlayer
@onready var カメラ: Camera3D = $"オブジェクト中心/演出カメラ"

var 都市ルート:オープンワールド管理クラス
var 表示リスト:Array[String]
var 一時チャンク解放用:Array[チャンク管理クラス]
var 停止準備完了: bool = false
var セリフ再生中:bool
var 音声有効:bool

func _ready() -> void:
	if has_node("街全体ビュー"):
		var 街ノード:Node3D=get_node("街全体ビュー")
		remove_child(街ノード)
		街ノード.queue_free()
	for 強制表示するチャンク:String in 表示チャンク:
		var チャンク名:String=ResourceUID.uid_to_path(強制表示するチャンク)
		if チャンク名.containsn(",a."):
			#チャンク名=チャンク名.get_file()
			チャンク名=チャンク名.get_file().split(".")[0]+"_Chunk"
			表示リスト.append(チャンク名)
			#print(i)
	if not Engine.is_editor_hint():
		hide()
		#var デバッグモード:bool=true
		if 都市ルート or get_tree().get_first_node_in_group("全体制御") and get_tree().get_first_node_in_group("全体制御").レベルルート:
			#デバッグモード=false
			if 再生前条件更新フラグ名!="":
				if 条件フラグ加算から上書き:
					データロガー.ミッション条件フラグ保存(再生前条件更新フラグ名,再生前条件フラグ加算数)
				else:
					データロガー.ミッション条件フラグ保存(再生前条件更新フラグ名,データロガー.ミッション条件取得(再生前条件更新フラグ名)+再生前条件フラグ加算数)
			for アクセスノード名:String in 表示リスト:
				if 都市ルート.has_node(アクセスノード名):
					var チャンクルート:チャンク管理クラス=都市ルート.get_node(アクセスノード名)
					チャンクルート.強制表示()
					一時チャンク解放用.append(チャンクルート)
			#再生後のフラグではあるが、ブチ切り対策のため、再生前に持ってきている。
			if 再生後フラグ!="":
				データロガー.フラグ追加(再生後フラグ)
				データロガー.全保存()
			if 再生後発生ミッション and !再生後発生ミッション.is_empty():
				for i:ミッションデータ in 再生後発生ミッション:
					データロガー.ミッションフラグ追加(i)
		if not get_parent() is Node3D:
			#print(get_parent())
			await  調整用街表示(true)
			show()
			演出開始()
		else:
			for デバッグ用削除ノード:Node in 削除対象:
				デバッグ用削除ノード.queue_free()
		音声有効=データロガー.システム設定読み込み("音声有効")
	print(表示リスト)
	var スキップカウンター:int=0
	while true and not Engine.is_editor_hint():
		await get_tree().create_timer(0.1).timeout
		if Input.is_action_pressed("アニメーションスキップ"):
			スキップカウンター+=1
		else:
			スキップカウンター=0
		if スキップカウンター>10:
			演出終了()
			break



# 外部（メッセージボックス等）から再開させるために使う
func アニメーション再開()->void:
	アニメーション.play()

# 子クラスでこの関数をオーバーライドして中身を書く
func 演出開始()->void:
	show()
	if カメラ:
		カメラ.make_current()
	if アニメーション:
		アニメーション.play("開始")
	if プレイヤー再生前ワープ and get_tree().get_first_node_in_group("プレイヤー"):
		get_tree().get_first_node_in_group("プレイヤー").global_position=$"オブジェクト中心/プレイヤー開始位置".global_position

func セリフ呼び出し(誰: String,番号: int)->void:
	セリフ表示(誰, セリフ集[番号])


func セリフ表示(誰: String, 内容: セリフオブジェクト)->void:
	if not get_tree().get_first_node_in_group("UI"):
		get_tree().root.add_child(load("res://GUI/UI.tscn").instantiate())
		for デバッグ用UI:Control in get_tree().get_first_node_in_group("UI").get_children():
			if not デバッグ用UI is メッセージボックスクラス:
				デバッグ用UI.hide()
		#var s:PackedScene
		#s.instantiate()
	var ボックス:メッセージボックスクラス = get_tree().get_first_node_in_group("UI").get_node("メッセージボックス")
	
	# ボックスを表示状態にする（既存の表示ロジックの一部を流用）
	ボックス.show()
	if 誰!="":ボックス.名前.text = 誰
	else:誰=ボックス.名前.text
	ボックス.メッセージラベル.text = 内容.セリフ
	if 音声有効:
		ボックス.get_node("AudioStreamPlayer").stream=内容.ボイス
		ボックス.get_node("AudioStreamPlayer").play()
		
	
	var 対象:Node3D=エンティティ取得(誰)
	if 対象:
		対象.表情切り替え(内容.表情)
		
		
	# 【重要】ここでアニメを止め、プレイヤーがボタンを押すまで待つ
	# メッセージボックスクラスが発行するシグナルを待機する
	#アニメ.pause()
	#ボイスの進行を検討
	while not 停止準備完了:
		await get_tree().process_frame
	await ボックス.ログ進行
	停止準備完了 = false
	# ボタンが押されたらアニメ再開
	ボックス.hide()
	アニメーション.play()

func 停止ポイント設定()->void:
	if not get_parent() is Node3D and not get_tree().get_first_node_in_group("UI"):
		return
	停止準備完了 = true
	アニメーション.pause() # ここでアニメが止まる

func エンティティ取得(名前:String)->Node:
	return $"オブジェクト中心".get_node(名前)


# アニメーションの最後や、特定のタイミングで呼び出す
func 演出終了(フェードアウト有効:bool=false)->void:
	if get_tree().get_first_node_in_group("UI"): get_tree().get_first_node_in_group("UI").get_node("メッセージボックス").強制終了()
	if フェードアウト有効:
		if get_tree().get_first_node_in_group("UI"):
			var フェードアウト:画面フェードクラス = get_tree().get_first_node_in_group("UI").get_node("画面フェード")
			フェードアウト.フェードアウト()
			await get_tree().create_timer(1).timeout
			フェードアウト.フェードイン()
	演出完了通知.emit()
	if プレイヤー再生後ワープ and get_tree().get_first_node_in_group("プレイヤー"):
		get_tree().get_first_node_in_group("プレイヤー").global_position=$"オブジェクト中心/プレイヤー終了位置".global_position
	if 再生後フラグ!="":
		データロガー.フラグ追加(再生後フラグ)
		データロガー.全保存()
	

func フェード(アウト:bool=false)->void:
	if get_tree().get_first_node_in_group("UI"):
		var フェードアウト:画面フェードクラス = get_tree().get_first_node_in_group("UI").get_node("画面フェード")
		if アウト:
			フェードアウト.フェードアウト()
		else:
			フェードアウト.フェードイン()

func リスト内レベル基礎判断(リスト:Array[Node])->bool:
	for i:Node in リスト:
		if i is レベル基礎クラス:
			return true
	return false
func 調整用街表示(デバッグ=false)->void:
	if has_node("街全体ビュー"):
		get_node("街全体ビュー").queue_free()
		return
	
	print_rich("[color=green]街読み込み中…[/color]")
	await  get_tree().create_timer(0.01).timeout
	if Engine.is_editor_hint() or not Engine.is_editor_hint() and not リスト内レベル基礎判断(削除対象):
		var シーン:PackedScene=load("res://使わない/街全体ビュー.tscn")
		var ノード:デバッグ用街シーン=シーン.instantiate()
		ノード.set("デバッグ",デバッグ)
		add_child(ノード)
		if Engine.is_editor_hint():
			var アタッチスクリプト:Script= load("res://使わない/演出チャンク定義ツール.gd")
			#前提として子ノードは1つしか存在しないはずのため↓
			for 子ノード:Node3D in ノード.get_children()[0].get_children():
				var メッシュ:MeshInstance3D=子ノード.get_children()[0]
				if メッシュ is MeshInstance3D:
					メッシュ.set_script(アタッチスクリプト)
					メッシュ.set("演出基盤",self)
					メッシュ.owner=self
		#シーンとして保存させないため↓
		#ノード.owner=self
		ノード.position.y=-50
		ノード.rotation_degrees.x=0
		ノード.scale=Vector3(16,16,16)
	
		if not 表示リスト.is_empty():
			var 街全体:Node3D=ノード.get_node("街全体ビュー")
			for チャンクルート:Node3D in 街全体.get_children():
				if not 表示リスト.has(チャンクルート.name):
					チャンクルート.queue_free()
	
	print_rich("[color=green]完了！！[/color]")
	

	
func _exit_tree() -> void:
	for チャンクルート in 一時チャンク解放用:
		チャンクルート.強制表示解除()
