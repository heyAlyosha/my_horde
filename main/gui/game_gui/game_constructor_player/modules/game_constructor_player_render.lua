-- Отрисовка
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local color = require("color-lib.color")
local storage_game = require "main.game.storage.storage_game"
local game_constructor_player_btns = require "main.gui.game_gui.game_constructor_player.modules.game_constructor_player_btns"
local game_content_bots = require "main.game.content.game_content_bots"

function M.render(self, player_index, game_constructor_player_selects)
	self.player = storage_game.family.settings.players[player_index]

	self.array_bots = game_constructor_player_selects.bots

	-- Включаем тип настроек
	gui_loyouts.set_enabled(self, self.nodes.wrap_settings_gamer, self.player.type == "player")
	gui_loyouts.set_enabled(self, self.nodes.wrap_settings_bot, self.player.type == "bot")

	if self.player.type == "player" then
		M.player(self, self.player, game_constructor_player_selects)

	elseif self.player.type == "bot" then
		M.bot(self, self.player, game_constructor_player_selects)

		game_constructor_player_selects.listen_bot(self)
		
	end

	game_constructor_player_selects.listen_type(self)
end

-- Отрисовка настроек игрока
function M.player(self, player, game_constructor_player_selects)
	
	game_constructor_player_btns.add_btns_player(self)

	game_constructor_player_selects.listen_type(self)
	game_constructor_player_selects.listen_color(self)
	game_constructor_player_selects.listen_avatar(self)
end

-- Отрисовка настроек ,jnf
function M.bot(self, player, game_constructor_player_selects)
	local bot = game_content_bots.get(self.player.bot_id)

	gui_lang.set_text_upper(self, self.nodes.bot_name, "_name_to_game", before_str, ": "..bot.name)

	local complexity = lang_core.get_text(self, "_" .. bot.complexity, before_str, after_str, values)
	gui_lang.set_text_upper(self, self.nodes.bot_complexity, "_complexity", before_str, ": "..complexity)

	local character = lang_core.get_text(self, "_character_" .. bot.character, before_str, after_str, values)
	gui_lang.set_text_upper(self, self.nodes.bot_character, "_character", before_str, ": "..character)

	game_constructor_player_btns.add_btns_bot(self)

end

return M