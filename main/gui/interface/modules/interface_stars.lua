-- Функции для отрисовки звёздочек в интерфейсе
local M = {}

local storage_player = require "main.storage.storage_player"
local core_player_function = require "main.core.core_player.modules.core_player_function"
local gui_size = require "main.gui.modules.gui_size"
local gui_animate = require "main.gui.modules.gui_animate"
local timer_linear = require "main.modules.timer_linear"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local lang_core = require "main.lang.lang_core"

-- Размеры
M.sizes_wrap = {
	hidden  = {
		stars = vmath.vector3(300, 98, 0),
		stars_body = vmath.vector3(295, 95, 0),
	},
	visible  = {
		stars = vmath.vector3(300, 300, 0),
		stars_body = vmath.vector3(295, 295, 0),
	},
}

-- Добавил или убавили звёздочки
function M.visible(self, visible)
	self.visible_stars = visible

	for i = #self.btns, 1, -1 do
		local btn = self.btns[i]

		if btn.id == "stars" then
			table.remove(self.btns, i)
		end
	end

	if visible then
		-- ставим после кнопок 
		local position_x = 0
		for i, btn in ipairs(self.btns) do
			if btn.id ~= "stars" then
				position_x = position_x + gui.get_size(btn.node).x + 20
			end
		end

		--gui_loyouts.set_position(self, self.nodes.stars_wrap, -position_x, "x")

		-- Добавляем кнопку
		table.insert(self.btns, 1, {
			id = "stars", 
			type = "btn", 
			section = "interface_right", 
			node = self.nodes.stars,
			wrap_node = self.nodes.stars,
			node_title = false, 
			wrap_icon = "bg_modal_"
		})
	else
		-- Удаляем кнопку, если есть
		for i, btn in ipairs(self.btns) do
			if btn.id == "stars" then
				table.remove(self.btns, i)
			end
		end
	end
	gui_loyouts.set_enabled(self, self.nodes.stars_wrap, visible)
end

-- Добавил или убавили звёздочки
function M.set_star(self, stars, unwrap)
	timer_linear.add(self, "stars", 0, function (self)
		if self.set_star_timer then
			self.set_star_timer.stop(self)
			self.set_star_timer = nil
		end
		msg.post("main:/sound", "play", {sound_id = "modal_top_2_2"})
		self.set_star_timer = gui_animate.areol(self, "aoreol_template", speed_to_second, "loop", function_end, scale)
		gui.animate(self.nodes.stars_wrap, "scale", vmath.vector3(1.1), gui.EASING_LINEAR, 0.25)
	end)
	
	-- Анимация звёздочек
	timer_linear.add(self, "stars", 1, function (self)
		for star_i = 1, 3, 1 do
			local node_star = self.nodes["star_"..star_i]
			local sprite = gui.get_flipbook(node_star)
			local get_active = sprite == hash("star_active")
			local set_active = star_i <= stars

			if set_active ~= get_active then
				gui_animate.set_star(self, node_star, duration, delay, function_end_animation, set_active)
				gui_animate.set_star(self, self.nodes["list_item_"..star_i].icon, duration, delay, function_end_animation, set_active)
			end
		end
	end)

	timer_linear.add(self, "stars", 0.5, function (self)
		self.set_star_timer.stop(self)
		self.set_star_timer = nil
		gui.animate(self.nodes.stars_wrap, "scale", vmath.vector3(1), gui.EASING_LINEAR, 0.25)
	end)

	--
	if unwrap and stars < 3 then
		
		timer_linear.add(self, "stars", 0.5, function (self)
			M.unwrap(self, true, true)
		end)
		timer_linear.add(self, "stars", 5, function (self)
			M.unwrap(self, false, true)
		end)
		
	end
end

-- Развернуть или свернуть
function M.unwrap(self, unwrap, animated)
	local duration = 0.25
	if not animated then
		duration = 0
	end
	local function function_unwrap(self)
		local sizes
		msg.post("main:/sound", "play", {sound_id = "popup_hidden"})
		if self.timer_unwrap then
			timer.cancel(self.timer_unwrap)
			self.timer_unwrap = nil
		end
		self.unwrap = unwrap
		if unwrap then
			sizes = M.sizes_wrap.visible

			self.timer_unwrap = timer.delay(10, false, function (self)
				M.unwrap(self, false)
			end)
		else
			sizes = M.sizes_wrap.hidden
		end

		gui_loyouts.set_enabled(self, self.nodes.wrap_list, unwrap)

		gui.animate(self.nodes.stars, 'size', sizes.stars, gui.EASING_LINEAR, duration, 0,  function (self)
			gui_loyouts.set_size(self, self.nodes.stars, sizes.stars)
		end)
		gui.animate(self.nodes.stars_body, 'size', sizes.stars_body, gui.EASING_LINEAR, duration, 0, function (self)
			gui_loyouts.set_size(self, self.nodes.stars_body, sizes.stars_body)
		end)
	end

	if not animated then
		duration = 0
		function_unwrap(self)
	else
		gui_animate.pulse(self, self.nodes.stars, scale, duration, delay, function_unwrap)
	end

end

-- Записываем контент
function M.set_content(self, stars, list)
	self._stars_content = self._stars_content or {}

	self.stars = stars or 0
	local list = list or {}

	for i = 1, 3 do
		-- Отрисовываем завёздочки
		if stars < i   then
			gui_loyouts.play_flipbook(self, self.nodes["star_"..i], "star_default")
			gui_loyouts.play_flipbook(self, self.nodes["list_item_"..i].icon, "star_default")
			
		else
			gui_loyouts.play_flipbook(self, self.nodes["star_"..i], "star_active")
			gui_loyouts.play_flipbook(self, self.nodes["list_item_"..i].icon, "star_active")
		end

		-- Отрисовываем текст в списке
		local item_list = list[i]

		local node_content = self.nodes["list_item_" .. i].content
		local text = ""

		local id = gui.get_id(node_content)

		if item_list then
			text = item_list
		end

		--[[
		if not self._stars_content[id] then
			
			self._stars_content[id] = self.druid:new_text(, )
		else
			self._stars_content[id]:set_to(text)
		end
		--]]
		
		gui_loyouts.set_druid_text(self, node_content, text)
	end
end

return M