-- Отрисовка фокуса на элементах интефейса
local M = {}

local color = require("color-lib.color")
local gui_loyouts = require "main.gui.modules.gui_loyouts"

function M.render_focus_item(self, btn, focus)
	local color_name = ""
	local img_postfix = ""
	local node = nil

	-- Находим навзания картинки и цвета для статуса фокуса 
	if focus then
		color_name = "lime"
		img_postfix = "focus"
	else
		color_name = "white"
		img_postfix = "default"

		-- если нет фокуса и это инпут, сбрасываем с него фокус
		if btn.type == "input" then
			btn.input:unselect()			
		end
	end

	if btn and btn.type == "wrap" then
		-- Обёртка блока
		gui.set_color(btn.node_title, color[color_name])
		node = btn.node_title

	elseif btn and btn.type == "btn" then
		node = btn.node or btn.node_bg or btn.wrap_node
		-- Обычная кнопка
		if btn.icon and utf8.sub(btn.icon, 1, 8) == "btn_icon" then
			-- Если иконка, которую нужно окрасить
			if btn.node and btn.icon then
				gui.play_flipbook(btn.wrap_node, btn.icon .. "default")
				gui.set_color(btn.wrap_node, color[color_name])
			end

			if btn.node_bg and btn.icon then
				gui.play_flipbook(btn.wrap_node, btn.icon .. "default")
				gui.set_color(btn.wrap_node, color[color_name])
			end

		else
			if btn.node and btn.icon then
				gui.play_flipbook(btn.node, btn.icon .. img_postfix)
			end

			if btn.node_bg and btn.icon then
				gui.play_flipbook(btn.node_bg, btn.icon .. img_postfix)
			end
		end

		if btn.node_title then
			gui.set_color(btn.node_title, color[color_name])
		end

		if btn.node_wrap_title then
			gui.set_color(btn.node_wrap_title, color[color_name])
		end

		if btn.wrap_node and btn.wrap_icon then
			if not btn.color_icon and utf8.sub(btn.wrap_icon, 1, 8) == "btn_icon" then
				gui.play_flipbook(btn.wrap_node, btn.wrap_icon .. "default")
				gui.set_color(btn.wrap_node, color[color_name])

			elseif not btn.color_icon then
				gui.play_flipbook(btn.wrap_node, btn.wrap_icon .. img_postfix)
				gui.set_color(btn.wrap_node, vmath.vector3(1))
			else
				gui.play_flipbook(btn.wrap_node, btn.wrap_icon .. "default")
				gui.set_color(btn.wrap_node, btn.color_icon)
			end
		end

	elseif btn and btn.type == "text" then
		node = btn.nodes[#btn.nodes]
		-- Просто текст
		for i = 1, #btn.nodes do
			local node = btn.nodes[i]
			gui.set_color(node, color[color_name])
		end

	elseif btn and btn.type == "input" then
		node = btn.nodes.input_wrap
		-- Ввод текста
		if btn.nodes.input_wrap then
			gui.play_flipbook(btn.nodes.input_wrap, btn.input_bg_image .. img_postfix)
		end

		if btn.nodes.title then
			gui.set_color(btn.nodes.title, color[color_name])
		end

		
	elseif btn and btn.type == "slider" then
		node = btn.nodes.circle
		-- Ползунок
		if btn.nodes.circle then
			gui.play_flipbook(btn.nodes.circle, btn.bg_image .. img_postfix)
		end

		if btn.nodes.line then
			gui.play_flipbook(btn.nodes.circle, btn.bg_image .. img_postfix)
		end

		if btn.nodes.title then
			gui.set_color(btn.nodes.title, color[color_name])
		end

	elseif btn and btn.type == "switch" then
		node = btn.nodes.line
		local img = "bg_switch_"
		-- Ползунок
		if node then
			gui.play_flipbook(node, img .. img_postfix)
		end

		if btn.nodes.title then
			gui.set_color(btn.nodes.title, color[color_name])
		end

	end

	if btn.disabled then
		gui.set_alpha(node, 0.5)
	else
		gui.set_alpha(node, 1)
	end
end

return M