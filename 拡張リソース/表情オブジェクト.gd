extends Resource
class_name 表情オブジェクト
enum 表情{通常,右,右目,右目右,右目左,左,左目,左目右,左目左,閉,両目}

@export var 通常:CompressedTexture2D
@export var 右:CompressedTexture2D
@export var 右目:CompressedTexture2D
@export var 右目右:CompressedTexture2D
@export var 右目左:CompressedTexture2D
@export var 左:CompressedTexture2D
@export var 左目:CompressedTexture2D
@export var 左目右:CompressedTexture2D
@export var 左目左:CompressedTexture2D
@export var 閉:CompressedTexture2D
@export var 両目:CompressedTexture2D

		
		
func 取得(アクセス番号:表情)->CompressedTexture2D:
	var リスト:Array[StringName]=["通常","右","右目","右目右","右目左","左","左目","左目右","左目左","閉","両目"]
	return get(リスト[アクセス番号])
