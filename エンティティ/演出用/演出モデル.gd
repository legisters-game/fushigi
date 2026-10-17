@tool
extends "res://エンティティ/プレイヤー/model/モデル.gd"
class_name 演出モデルクラス
@export var オーバーライド:bool
@export var NPCオーバーライド:スケジュール管理クラス.NPC
@export var プレイヤーの見た目をジャック:bool
@export var 子を隠す:bool

var 引き継ぎ_追従:Array[BoneAttachment3D]
#@export_tool_button("キャストオフ") var グロー=
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if get_parent()is Node3D and 子を隠す:
		#print(get_parent())
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		$"R-G MC Rig MoCap v1_0".owner=null
	
	
	
	if プレイヤーの見た目をジャック:
		プレイヤーにオーバーライド()
	elif オーバーライド:
		キャラクターオーバーライド()

func プレイヤーにオーバーライド()->void:
	if get_tree().get_first_node_in_group("NPC制御"):
		var 対象NPC:エンティティ=get_tree().get_first_node_in_group("プレイヤー")
		var モデルルート:Node3D
		if 対象NPC and 対象NPC.モデル:
			モデルルート=対象NPC.モデル
		var 欲しいノード:Node3D
		var モデル位置調整:Vector3
		var モデルサイズ調整:Vector3
		
		for 子ひっかけ:Node in get_children():
			if 子ひっかけ.has_node("GeneralSkeleton"):
				子ひっかけ.get_parent().remove_child(子ひっかけ)
				子ひっかけ.queue_free()
		
		モデルルート= モデルルート.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		
		if モデルルート:
			for 子ひっかけ:Node in モデルルート.get_children():
				if 子ひっかけ.has_node("GeneralSkeleton"):
					欲しいノード=子ひっかけ
					モデル位置調整=モデルルート.position
					モデルサイズ調整=モデルルート.scale
					break
			
		if 欲しいノード:
			for 切り離し:BoneAttachment3D in 引き継ぎ_追従:
				切り離し.get_parent().remove_child(切り離し)
			var IKリスト:Array[Node]=アニメーション用IKノード取得()
			for IK:Node in IKリスト:
				if IK is SpringBoneSimulator3D: IK.get_parent().remove_child(IK)
			
			var モデル依存名:String
			for 消すノード:Node in get_children():
				if 消すノード is not AnimationPlayer and not 消すノード.owner:
					if 消すノード.has_node("GeneralSkeleton"):
						
						消すノード.get_node("GeneralSkeleton").unique_name_in_owner = false
					消すノード.get_parent().remove_child(消すノード)
					モデル依存名=消すノード.name
					消すノード.queue_free()
			var 追加ノード:Node3D=欲しいノード
			欲しいノード.get_parent().remove_child(欲しいノード)
			add_child(追加ノード)
			追加ノード.name="R-G MC Rig MoCap v1_0"
			追加ノード.owner=$AnimationPlayer.owner
			for 子:Node in 追加ノード.get_children():
				子.owner=$AnimationPlayer.owner
				for 孫:Node in 子.get_children():
					孫.owner=$AnimationPlayer.owner
					for hi孫:Node in 孫.get_children():
						hi孫.owner=$AnimationPlayer.owner
			for 子ひっかけ:Node in 追加ノード.get_children():
				if 子ひっかけ.name=="GeneralSkeleton":
					for IK:Node in IKリスト:
						if IK is SpringBoneSimulator3D:
							子ひっかけ.add_child(IK)
					子ひっかけ.unique_name_in_owner=true
					
					for 追加ボーン:BoneAttachment3D in 引き継ぎ_追従:
							子ひっかけ.add_child(追加ボーン)
					
					break
			追加ノード.position=モデル位置調整
			追加ノード.scale=モデルサイズ調整
			$AnimationPlayer.root_node=".."
			#$AnimationPlayer.reset_section()
			$AnimationPlayer.clear_caches()
			
		scale=対象NPC.scale*scale
		
		メッシュ親=モデルルート.メッシュ親
		メッシュ親2=モデルルート.メッシュ親2
		顔=モデルルート.顔
		表情データ=モデルルート.表情データ
		顔ボーン=モデルルート.顔ボーン
		モデルルート.queue_free()
func キャラクターオーバーライド()->void:
	#var アニメーションリスト:AnimationLibrary=$AnimationPlayer.get_animation_library()
	if get_tree().get_first_node_in_group("NPC制御"):
		var 対象NPC:エンティティ=get_tree().get_first_node_in_group("NPC制御").NPC取得(NPCオーバーライド)
		var モデルルート:Node3D
		if 対象NPC and 対象NPC.モデル:
			モデルルート=対象NPC.モデル
		var 欲しいノード:Node3D
		var モデル位置調整:Vector3
		var モデルサイズ調整:Vector3
		
		if モデルルート:
			for 子ひっかけ:Node in モデルルート.get_children():
				if 子ひっかけ.has_node("GeneralSkeleton"):
					欲しいノード=子ひっかけ
					モデル位置調整=モデルルート.position
					モデルサイズ調整=モデルルート.scale
					break
			
		if 欲しいノード:
			var IKリスト:Array[Node]=アニメーション用IKノード取得()
			for IK:Node in IKリスト:
				if IK is SpringBoneSimulator3D: IK.get_parent().remove_child(IK)
			for 消すノード:Node in get_children():
				if 消すノード is not AnimationPlayer and not 消すノード.owner:
					if 消すノード.has_node("GeneralSkeleton"):
						消すノード.get_node("GeneralSkeleton").unique_name_in_owner = false
					消すノード.queue_free()
			var 追加ノード:Node3D=欲しいノード.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
			add_child(追加ノード)
			
			追加ノード.owner=$AnimationPlayer.owner
			for 子:Node in 追加ノード.get_children():
				子.owner=$AnimationPlayer.owner
				for 孫:Node in 子.get_children():
					孫.owner=$AnimationPlayer.owner
					for hi孫:Node in 孫.get_children():
						hi孫.owner=$AnimationPlayer.owner
			for 子ひっかけ:Node in 追加ノード.get_children():
				if 子ひっかけ.name=="GeneralSkeleton":
					子ひっかけ.unique_name_in_owner=true
					for IK:Node in IKリスト:
						if IK is SpringBoneSimulator3D:
							子ひっかけ.add_child(IK)
					
			追加ノード.position=モデル位置調整
			追加ノード.scale=モデルサイズ調整
			$AnimationPlayer.root_node=".."
			#$AnimationPlayer.reset_section()
			
			$AnimationPlayer.clear_caches()
			
		


func アニメーション用IKノード取得()->Array[Node]:
	return find_children("*","SpringBoneSimulator3D",true,false)
	
func グローさせる()->void:
	var アニメーション:Tween=get_tree().create_tween()
	アニメーション.bind_node(self)
	if メッシュ親:
		for メッシュ in メッシュ親.get_children():
			if メッシュ is MeshInstance3D:
				var 変更マテリアル:StandardMaterial3D=メッシュ.get_surface_override_material(0)
				変更マテリアル.grow=true
				変更マテリアル.grow_amount=0
				アニメーション.parallel().tween_property(変更マテリアル,"grow_amount",2,0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if メッシュ親2:
		for メッシュ in メッシュ親2.get_children():
			if メッシュ is MeshInstance3D:
				var 変更マテリアル:StandardMaterial3D=メッシュ.get_surface_override_material(0)
				変更マテリアル.grow=true
				変更マテリアル.grow_amount=0
				アニメーション.parallel().tween_property(変更マテリアル,"grow_amount",2,0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				
	await アニメーション.finished
	await get_tree().create_timer(1).timeout
	
	if メッシュ親:
		for メッシュ in メッシュ親.get_children():
			if メッシュ is MeshInstance3D:
				var 変更マテリアル:StandardMaterial3D=メッシュ.get_surface_override_material(0)
				変更マテリアル.grow=false
				変更マテリアル.grow_amount=0
	if メッシュ親2:
		for メッシュ in メッシュ親.get_children():
			if メッシュ is MeshInstance3D:
				var 変更マテリアル:StandardMaterial3D=メッシュ.get_surface_override_material(0)
				変更マテリアル.grow=false
				変更マテリアル.grow_amount=0
	
