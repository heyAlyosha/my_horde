-- Функции для хода в игре
local M = {}

local storage_game = require "main.game.storage.storage_game"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_round_step_sector_core = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_core"
local game_core_round_step_functions = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_functions"
local game_core_round_response = require "main.game.core.round.modules.game_core_round_response"
local game_core_gamers = require "main.game.core.game_core_gamers"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

-- Игрок наступил на сектор
function M.start(self, sector_id, player_id)
	self.sector = game_content_wheel.get_item(self, sector_id)

	msg.post("main:/music", "play", {sound = "music-gameplay", loop = nil})

	-- Ставим нужный лайоут
	core_layouts.set_data("round_game", {step = "sector", sector_id = sector_id})

	if player_id then
		self.player = game_core_gamers.get_player(self, player_id, game_content_wheel)
		core_layouts.set_data("round_game", {player = self.player, step = "sector", sector_id = sector_id, index_player = self.player.index})

	else
		self.player = core_layouts.get_data().data.player

	end

	game_core_round_step_sector_core.start(self, self.sector)

	

end

-- Ловим события
function M.on_event(self, message_id, message)
	if message.id == "get_refresh_quest" then
		--Повтор вопроса
		game_core_round_functions.show_quest(self, false)

	elseif message.id == "get_full_word" then
		-- Запрос на окно ввода слова целиком
		msg.post("/loader_gui", "visible", {
			id = "game_word",
			visible = true,
			type = hash("animated_close")
		})
		msg.post("/loader_gui", "visible", {
			id = "keyboard_ru",
			visible = false,
		})
		local name = utf8.upper(self.player.name)
		local text_leader = lang_core.get_text(self, "_leader_player_full_word", before_str, after_str, {name = name})
		game_core_round_functions.bubble_leader(self, text_leader, text_leader)

	elseif message.id == "close_game_word" then
		-- закрывают окно ввода слова
		game_core_round_step_functions.get_keyboard(self, self.sector, self.player)

	elseif message.id == "key_activate_symbol" then
		-- Нажали на букву в клавиатуре
		local symbol = message.value.symbol
		game_core_round_response.start(self, symbol)
	end


	game_core_round_step_sector_core.on_event(self, message_id, message)
end

return M