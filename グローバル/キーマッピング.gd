extends Node
@export var キー文字:Dictionary[String,String]={
	# マウス
	"MOUSE_BUTTON_LEFT": "", "MOUSE_BUTTON_RIGHT": "", "MOUSE_BUTTON_MIDDLE": "", "MOUSE_BUTTON_WHEEL_UP": "", "MOUSE_BUTTON_WHEEL_DOWN": "", "MOUSE_BUTTON_WHEEL_LEFT": "", "MOUSE_BUTTON_WHEEL_RIGHT": "","MOUSE_BUTTON_XBUTTON1": "","MOUSE_BUTTON_XBUTTON2": "",
	
	# アルファベット
	"A": "", "B": "", "C": "", "D": "", "E": "", "F": "", "G": "", "H": "", "I": "", "J": "", "K": "", "L": "", "M": "", "N": "", "O": "", "P": "", "Q": "", "R": "", "S": "", "T": "", "U": "", "V": "", "W": "", "X": "", "Y": "", "Z": "",
	
	# 数字
	"0": "", "1": "", "2": "", "3": "", "4": "", "5": "", "6": "", "7": "", "8": "", "9": "",
	
	# ファンクション
	"F1": "", "F2": "", "F3": "", "F4": "", "F5": "", "F6": "", "F7": "", "F8": "", "F9": "", "F10": "", "F11": "", "F12": "", "F13": "", "F14": "", "F15": "", "F16": "",
	
	# 特殊・制御
	"Escape": "", "Tab": "", "Caps_Lock": "", "Shift": "", "Ctrl": "", "Alt": "", "Meta": "", "Space": "", "Menu": "", "Enter": "", "KP_Enter": "", "Backspace": "",
	"Insert": "", "Delete": "", "Home": "", "End": "", "PageUp": "", "PageDown": "", "Print": "", "Scroll_Lock": "", "Pause": "", "Num_Lock": "",
	
	# 矢印
	"Left": "", "Up": "", "Right": "", "Down": "",
	
	# 記号
	"QuoteLeft": "", "Minus": "", "Equal": "", "BracketLeft": "", "BracketRight": "", "Backslash": "", "Semicolon": "", "Quote": "", "Comma": "", "Period": "", "Slash": "",
	
	# テンキー
	"KP_0": "", "KP_1": "", "KP_2": "", "KP_3": "", "KP_4": "", "KP_5": "", "KP_6": "", "KP_7": "", "KP_8": "", "KP_9": "",
	"KP_Multiply": "", "KP_Divide": "", "KP_Subtract": "", "KP_Add": "", "KP_Period": "",
	
	# メディア・その他
	"Help": "", "Back": "", "Forward": "", "Stop": "", "Refresh": "", "VolumeDown": "", "VolumeMute": "", "VolumeUp": "", "MediaPlay": "", "MediaStop": "", "MediaPrevious": "", "MediaNext": "", "MediaRecord": ""
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in キー文字.keys():
		if キー文字[i]=="":
			キー文字[i]=i


func インプットイベントから入力イベントを文字で返す(インプットイベント:InputEvent)->String:
	if インプットイベント is InputEventKey:
		print(インプットイベント.get_physical_keycode_with_modifiers())
		return OS.get_keycode_string(インプットイベント.get_physical_keycode_with_modifiers())
	elif インプットイベント is InputEventMouseButton:
		match インプットイベント.button_index:
			MOUSE_BUTTON_LEFT: return "MOUSE_BUTTON_LEFT"
			MOUSE_BUTTON_RIGHT: return "MOUSE_BUTTON_RIGHT"
			MOUSE_BUTTON_MIDDLE: return "MOUSE_BUTTON_MIDDLE"
			MOUSE_BUTTON_WHEEL_UP: return "MOUSE_BUTTON_WHEEL_UP"
			MOUSE_BUTTON_WHEEL_DOWN: return "MOUSE_BUTTON_WHEEL_DOWN"
			MOUSE_BUTTON_WHEEL_LEFT: return "MOUSE_BUTTON_WHEEL_LEFT"
			MOUSE_BUTTON_WHEEL_RIGHT: return "MOUSE_BUTTON_WHEEL_RIGHT"
			MOUSE_BUTTON_XBUTTON1: return "MOUSE_BUTTON_XBUTTON1"
			MOUSE_BUTTON_XBUTTON2: return "MOUSE_BUTTON_XBUTTON2"
		return ""
	else:
		return ""
