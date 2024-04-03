-- функции для показа и отрисовки подробностей об объекте
local M = {}

local inventary_detail_render = require "main.gui.inventary_detail.modules.inventary_detail_render"


local game_content_characteristic = require "main.game.content.game_content_characteristic"
local gui_text = require "main.gui.modules.gui_text"
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local inventary_detail_sell = require "main.gui.inventary_detail.modules.inventary_detail_sell"
local inventary_detail_buy = require "main.gui.inventary_detail.modules.inventary_detail_buy"
local sound_render = require "main.sound.modules.sound_render"

-- Отрисовка отдельного объекта
function M.render(self, type, id)
	-- Получаем контент
	local btn_title = ""
	if type == "prize" then
		inventary_detail_render.prize(self, id, self.nodes)

	elseif type == "shop" then
		inventary_detail_render.shop(self, id, self.nodes)

	elseif type == "achieve" then
		inventary_detail_render.achieve(self, id, self.nodes)

	end
end

-- Нажатие на кнопку
function M.btn_activate(self, focus_btn_id)
	local btn = self.btns[focus_btn_id]

	if btn.disabled then return false end

	gui_animate.activate(self, btn.node)
	sound_render.play("activate_btn")

	if btn.id == "btn" then
		if self.btn_type == 'sell' then
			inventary_detail_sell.sell(self, self.content.id, self.content.type)

		elseif self.btn_type == 'reward' then
			inventary_detail_buy.reward(self, self.content.id, "artifact")

		elseif self.btn_type == 'buy' then
			inventary_detail_buy.buy(self, self.content.id, "artifact")
		end
			
	end
end

return M