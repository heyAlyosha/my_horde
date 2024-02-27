-- Отрисовка
local M = {}

local color = require("color-lib.color")

-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local game_content_artifact = require "main.game.content.game_content_artifact"
local storage_game = require "main.game.storage.storage_game"
local gui_input = require "main.gui.modules.gui_input"

-- Отрисовка каталога
function M.get_balance(self)
	--Баланс игрока
	local balance = 0

	if self.player and self.player.id and storage_game.family.bank[self.player.id] then
		balance = storage_game.family.bank[self.player.id]
	end

	return balance
end

-- Получение количества призов
function M.get_prizes(self, id)
	-- КОличество у игрока
	local count = 0
	if self.player and self.player.id and storage_game.family.inventaries[self.player.id] and storage_game.family.inventaries[self.player.id][id] then
		count = storage_game.family.inventaries[self.player.id][id]
	end

	return count
end

-- Получить игрока
function M.get_player_index(self)
	local start_index = self.player_index + 1

	for i = start_index, 3 do
		if storage_game.family.settings.players[i].type == "player" then
			return i
		end
	end

	return false
end

-- Активация
function M.activate_btn(self, btn)
	
end

-- Покупка
function M.buy(self, id, game_family_shop_render)
	local item = game_content_artifact.get_item(id)

	storage_game.family.inventaries[self.player.id] = storage_game.family.inventaries[self.player.id] or {}
	storage_game.family.inventaries[self.player.id][item.id] = storage_game.family.inventaries[self.player.id][item.id] or 0

	if item.id == "try_1" then
		item.price_buy = 250
	end

	if M.get_balance(self) >= item.price_buy then
		storage_game.family.bank[self.player.id] = storage_game.family.bank[self.player.id] or 0
		storage_game.family.bank[self.player.id] = storage_game.family.bank[self.player.id] - item.price_buy
		storage_game.family.inventaries[self.player.id][item.id] = storage_game.family.inventaries[self.player.id][item.id] + 1

		local last_focus = self.focus_btn_id
		game_family_shop_render.catalog(self)
		game_family_shop_render.player(self)

		msg.post("main:/sound", "play", {sound_id = "buy_1"})

		gui_input.set_focus(self, last_focus, function_post_focus, is_remove_other_focus)

		return true

	else
		msg.post("main:/sound", "play", {sound_id = "not_enouth_beep"})
		return false

	end
end

return M