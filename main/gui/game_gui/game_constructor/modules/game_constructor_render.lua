-- Храним кнопки для окна настроек
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local color = require("color-lib.color")
local storage_game = require "main.game.storage.storage_game"

-- Отрисовка всех игроков
function M.all_players(self)
	for index, player in ipairs(storage_game.family.settings.players) do
		M.player(self, index, player)
	end
end

-- Отрисовка игрока
function M.player(self, index, player)
	local nodes = {
		name = gui.get_node("player_"..index.."_template/name"),
		type = gui.get_node("player_"..index.."_template/type"),
		avatar = gui.get_node("player_"..index.."_template/avatar"),
	}

	gui_loyouts.set_text(self, nodes.name, utf8.upper(player.name))
	local player_color = color[player.color] or player.color
	gui_loyouts.set_color(self, nodes.name, player_color)

	local title_type = lang_core.get_text(self, "_type")
	local text_type = lang_core.get_text(self, "_"..player.type)
	gui_loyouts.set_text(self, nodes.type, utf8.upper(title_type .. " : ".. text_type))

	gui_loyouts.play_flipbook(self, nodes.avatar, player.avatar)

end



return M