-- Функции 
local M = {}

local gui_catalog = require "main.gui.modules.gui_catalog"
local gui_input = require "main.gui.modules.gui_input"
local gui_loader = require "main.gui.modules.gui_loader"

local storage_player = require "main.storage.storage_player"
local core_player_function = require "main.core.core_player.modules.core_player_function"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"

-- Отрисовка блока статистики
function M.render_stats(self)
	local level = storage_player.level or 1

	gui_lang.set_text(self, self.nodes.level, "_level", before_str, ": "..level)

	local stats = game_core_stats.update(self)

	local current_xp = storage_player.score or 1
	local next_xp = core_player_function.get_level_data_user().score_to_next_level
	gui_lang.set_text(self, self.nodes.xp, "_xp", before_str, ": "..current_xp .. "/" .. next_xp)

	local points = storage_player.characteristic_points or 0

	gui_lang.set_text(self, self.nodes.points, "_points_improvement", before_str, ": "..points)
	gui_lang.set_text(self, self.nodes.mission_complete, "_сompleted_missions", before_str, ": " .. stats.mission_complete .. '/'..stats.missions_all)
	gui_lang.set_text(self, self.nodes.company_complete, "_сompleted_company", before_str, ": " .. stats.company_complete .. '/' .. stats.company_all)

	local wins = storage_player.stats.wins or 0
	gui_lang.set_text(self, self.nodes.wins, "_win", before_str, ": " .. wins)

	local fails = storage_player.stats.fail or 0
	gui_lang.set_text(self, self.nodes.fails, "_fail", before_str, ": " .. fails)

end

return M