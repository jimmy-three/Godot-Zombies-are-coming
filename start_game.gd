extends Node2D

var language_list = ["zh_CN0", "en_US1", "ja_JP2"]
var lang_index = 0
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_language_pressed() -> void:
	lang_index = (lang_index + 1) % 3
	var transformed_lang = language_list[lang_index].substr(0, 5)
	TranslationServer.set_locale(transformed_lang)
	Global.language = language_list[lang_index]
	$StartGame.text = tr("STARTGAME")
	$Language.text = tr("LANGUAGE")
	$Language/CenterContainer/CurrentLanguage.text = tr("CURRENTLANGUAGE")
	$Attribution.text = "Made with Godot · godotengine.org/license\n" + tr("NOCOMMERCIAL")
	$GameInstruction.text = tr("GAMEINSTRUCTION")
	$GameInstruction/Panel/CenterContainer/Title.text = tr("GAMEINSTRUCTION")
	$GameInstruction/Panel/Instruction.text = tr("INSTRUCTIONCONTEXT")

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _on_game_instruction_pressed() -> void:
	$GameInstruction/Panel.visible = not $GameInstruction/Panel.visible
