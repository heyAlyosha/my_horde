-- Функции для магазина призов
local M = {}

local gui_animate = require "main.gui.modules.gui_animate"
local gui_catalog_prize_magazine = require "main.gui.modules.gui_catalog_prize_magazine"
local game_content_prize = require "main.game.content.game_content_prize"
local color = require("color-lib.color")
local storage_game = require "main.game.storage.storage_game"
local api_player = require "main.game.api.api_player"
local gui_input = require "main.gui.modules.gui_input"

function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("main:/loader_gui", "visible", {
			id = "catalog_prize_magazine",
			visible = false
		})
	end)
end

function M.function_activate(self, focus_btn_id)
	local btn = self.btns[focus_btn_id]

	gui_animate.activate(self, btn.node)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	msg.post("main:/core_study", "event", {
		type = "activate_btn",
		from_id = self.id
	})

	if btn.id == "close" then
		M.hidden(self)
	elseif btn.is_card then
		M.buy(self, btn.id)
	end
end

function M.buy(self, id)
	local card = self.cards_ids[id]
	local color_text = color.red
	local duration = 0.5
	local sound 
	local text_to_animate_up = "-"..card.price_buy
	local scale_wrap = vmath.vector3(1.35)

	msg.post("main:/loader_gui", "visible", {
		id = "study",
		visible = false
	})

	if card.price_buy <= self.score then
		self.score = self.score - card.price_buy
	else
		msg.post("main:/sound", "play", {sound_id = "nav_block_2"})
		
		return false
	end

	msg.post("main:/sound", "play", {sound_id = "buy_1"})

	-- Зачисляем
	card.count = card.count + 1

	storage_game.game.result.prizes[id] = storage_game.game.result.prizes[id] or 0
	storage_game.game.result.prizes[id] = storage_game.game.result.prizes[id] + 1

	local set_nakama = true
	api_player.set_prizes(self, id, 1, "add", set_nakama)

	gui_catalog_prize_magazine.update_catalog(self, self.cards, self.score)
	
	gui_animate.pulse_update_count(self, self.nodes.balance_wrap, self.nodes.balance_number, duration, delay, color_text, sound, text_to_animate_up, function_end_animation, scale_wrap)

	if not card.is_buy then
		timer.delay(0.25, false, function (self)
			local focus_btn = gui_catalog_prize_magazine.scroll_to_buy(self, self.id_catalog, self.cards)
			if not focus_btn then
				-- Не осталось призов для покупки, закрываем
				M.hidden(self)
			else
				focus_btn = focus_btn + 1
			end

			gui_input.set_focus(self, focus_btn)
		end)
	end

	for i, btn in ipairs(self.btns) do
		if not btn.is_buy then
			
			break
		end
	end
end

--
function M.clear_catalog(self)
	for i = #self.btns, 1, -1 do
		local item = self.btns[i]

		if item.id ~= "close" then
			gui.delete_node(item.wrap_node)
			table.remove(self.btns, i)
		end
	end
end

return M 