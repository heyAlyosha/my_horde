-- Функции для выбора цвета игрока
local M = {}

local color = require("color-lib.color")
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_input_type_select_arrow = require "main.gui.modules.gui_input.gui_input_type_select_arrow"
local lang_core = require "main.lang.lang_core"
local gui_lang = require "main.lang.gui_lang"
local game_content_bots = require "main.game.content.game_content_bots"
local game_constructor_player_render = require "main.gui.game_gui.game_constructor_player.modules.game_constructor_player_render"
local storage_game = require "main.game.storage.storage_game"

M.colors = {
	"aqua", 
	"aquamarine", 
	"chartreuse", 
	"coral", 
	"deeppink", 
	"deepskyblue", 
	"fuchsia", 
	"gold", 
	"greenyellow", 
	"orangered"
}

M.types = {
	"player", 
	"bot"
}

M.avatars = {
	"icon-gamer-1", 
	"icon-gamer-2",
	"icon-gamer-3",
	"icon-gamer-4",
	"icon-gamer-5",
	"icon-gamer-6",
	"icon-gamer-7",
	"icon-gamer-8",
	"icon-gamer-9",
}

M.bots = {
	"andrew", "denis", "igor", "ira", "lena", "max", "alyona", "antonina", "lyosha", "proskovia"  
}

-- Пролистываем типы 
function M.listen_type(self, id)
	local current_value = self.player.type
	local array_values = M.types

	return gui_input_type_select_arrow.listen(self, id, current_value, array_values, function (self, value, index)
		if self.player.type ~= value then
			self.player.type = value

			if self.player.type == "bot" then
				self.player.bot_id = M.bots[1]
				local bot_content = game_content_bots.get(self.player.bot_id)

				for k, v in pairs(bot_content) do
					if k == "id" then
						self.player[k] = "player_"..self.player_index
					else
						self.player[k] = v
					end
				end

				M.listen_bot(self, nil)

			else
				self.player.id = "player_"..self.player_index
				self.player.type = "player"
				self.player.name = "Игрок "..self.player_index
				self.player.avatar = M.avatars[self.player_index]
				self.player.color = M.colors[self.player_index]

			end
			
			game_constructor_player_render.render(self, self.player_index, M)
		end
		gui_lang.set_text_upper(self, self.nodes.type_value, "_"..value, before_str, after_str)

	end)
end

-- Пролистываем цвета
function M.listen_color(self, id)
	local current_value = self.player.color
	local array_values = M.colors
	
	return gui_input_type_select_arrow.listen(self, id, current_value, array_values, function (self, value, index)
		self.player.color = value
		gui_loyouts.set_color(self, self.nodes.color_box, color[self.player.color])

	end)
end

-- Пролистываем аватарки
function M.listen_avatar(self, id)
	local current_value = self.player.avatar
	local array_values = M.avatars

	return gui_input_type_select_arrow.listen(self, id, current_value, array_values, function (self, value, index)
		self.player.avatar = value
		gui_loyouts.play_flipbook(self, self.nodes.avatar_value, self.player.avatar)

	end)
end

-- Пролистываем ботов
function M.listen_bot(self, id)
	local current_value = self.player.bot_id

	local array_values = self.array_bots

	return gui_input_type_select_arrow.listen(self, id, current_value, array_values, function (self, value, index)
		self.player.bot_id = value
		local bot_content = game_content_bots.get(self.player.bot_id)

		for k, v in pairs(bot_content) do
			if k == "id" then
				self.player[k] = "player_"..self.player_index
			else
				self.player[k] = v
			end
		end

		gui_loyouts.play_flipbook(self, self.nodes.bot_value, self.player.avatar)
		game_constructor_player_render.bot(self, self.player)

	end)
end

return M