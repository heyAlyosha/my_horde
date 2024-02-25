-- Храним кнопки для окна настроек
local M = {}

function M.add_btns(self)
	self.btns = {
		-- Кнопка закрытия
		{
			id = "close", 
			type = "btn", 
			section = "close", 
			node = self.nodes.btn_close, 
			wrap_node = self.nodes.btn_close_icon, 
			node_title = false, 
			icon = "btn_circle_bg_red_", 
			wrap_icon = "btn_icon_close_"
		},
		-- ОЧКИ ДЛЯ ПОКУПОК
		-- Снижение
		{
			id = "prev_score", 
			type = "btn", 
			section = "score", 
			node = self.nodes.btn_score_left,
			node_title = self.nodes.btn_score_left,
			node_wrap_title = self.nodes.score_title,
		},
		-- Увеличение
		{
			id = "next_score", 
			type = "btn", 
			section = "score", 
			node_bg = self.nodes.btn_score_right,
			node_title = self.nodes.btn_score_right,
			node_wrap_title = self.nodes.score_title,
		},
		-- Кнопка
		{
			id = "edit_player_1",
			player_index = 1,
			type = "btn", 
			section = "4", 
			node = gui.get_node('player_1_template/btn_template/btn_wrap'),
			node_wrap_title = gui.get_node("player_1_template/type"),
			icon = "button_default_green_",
		},
		{
			id = "edit_player_2",
			player_index = 2,
			type = "btn", 
			section = "5", 
			node = gui.get_node('player_2_template/btn_template/btn_wrap'),
			node_wrap_title = gui.get_node("player_2_template/type"),
			icon = "button_default_green_",
		},
		{
			id = "edit_player_3",
			player_index = 3,
			type = "btn", 
			section = "6", 
			node = gui.get_node('player_3_template/btn_template/btn_wrap'),
			node_wrap_title = gui.get_node("player_3_template/type"),
			icon = "button_default_green_",
		},
		-- Кнопка начала игры
		{
			id = "play", 
			type = "btn", 
			section = "play", 
			node = self.nodes.btn_play, 
			wrap_node = self.nodes.btn_play_icon, 
			node_title = false, 
			icon = "btn_circle_bg_green_", 
			wrap_icon = "btn_icon_play_",
			
		},
	}

	return self.btns
end

return M