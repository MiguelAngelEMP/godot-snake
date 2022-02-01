extends Control


func update_score(score:int):
	get_node("PanelScore/Score").set_text("Score: %05d" % score)


func update_max_score(max_score:int):
	get_node("PanelMaxScore/MaxScore").set_text("Max Score: %05d" % max_score)


func toggle_start_panel():
	get_node("PanelStart").set_visible(not get_node("PanelStart").is_visible())
