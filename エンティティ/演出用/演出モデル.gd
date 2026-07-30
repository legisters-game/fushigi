@tool
extends "res://エンティティ/プレイヤー/model/モデル.gd"
@export var オーバーライド:bool
@export var NPCオーバーライド:スケジュール管理クラス.NPC
@export var プレイヤーの見た目をジャック:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent()is Node3D:
		#print(get_parent())
		$"R-G MC Rig MoCap v1_0".owner=null
	super()
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
					for IK:Node in IKリスト:
						if IK is SpringBoneSimulator3D:
							子ひっかけ.add_child(IK)
					子ひっかけ.unique_name_in_owner=true
			追加ノード.position=モデル位置調整
			追加ノード.scale=モデルサイズ調整
			$AnimationPlayer.root_node=".."
			#$AnimationPlayer.reset_section()
			$AnimationPlayer.clear_caches()

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
