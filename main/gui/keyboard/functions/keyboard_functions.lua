-- Функции
local M = {}

local color = require("color-lib.color")
local gui_animate = require "main.gui.modules.gui_animate"
local gui_input = require "main.gui.modules.gui_input"
local storage_game = require "main.game.storage.storage_game"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"

-- Показываем 
function M.visible(self, data)
	local is_player = data.is_player
	local keys_disabled = data.keys_disabled or {}
	self.type = data.type or "input"

	-- Отрисовываем кнопки
	M.render_btns(self, data)

	-- Кешируем кнопки по символам
	self.btns_symbol = {}
	for i, btn in ipairs(self.btns) do
		if btn.is_key then
			local symbol = M.get_symbol(btn)

			self.btns_symbol[symbol] = btn
		end
	end

	-- Блокируем указанные буквы
	for i, symbol in ipairs(keys_disabled) do
		local symbol = utf8.lower(symbol)

		local btn = self.btns_symbol[symbol]

		if btn then
			gui_input.set_disabled(self, btn, true)
		end
	end

	-- Если это игрок - ставим фокус и разблокируем управление
	self.disabled = not is_player
	if is_player then
		timer.delay(0.2, false, function(self)
			for i, item in ipairs(self.btns) do
				if not item.disabled and item.is_key then
					gui_input.set_focus(self, i)
					return
				end
			end
		end)

	else
		-- Блокируем кнопки управления внизу
		for i = #self.btns, #self.btns - 3, -1 do
			gui_input.set_disabled(self, self.btns[i], true)
		end

		-- Смотрим какие буквы остались
		storage_game.bot.keyboard = {}
		for i, btn in ipairs(self.btns) do
			if not btn.disabled and btn.is_key then
				storage_game.bot.keyboard[#storage_game.bot.keyboard + 1] = {
					symbol = M.get_symbol(btn),
					index = i
				}
			end
		end

	end

	-- Для игры или для ввода текста
	
	if self.type == "input" then
		gui_lang.set_text_upper(self, self.nodes.btn_word_title, "_delete")
		gui_lang.set_text_upper(self, self.nodes.btn_refresh_title, "_space")
		gui_lang.set_text_upper(self, self.nodes.btn_surrender_title, "_close")
		--gui_input.set_disabled(self, self.btns[#self.btns], true)
		--self.not_remove_other_focus = true
	else
		gui_lang.set_text_upper(self, self.nodes.btn_word_title, "_open_word")
		gui_lang.set_text_upper(self, self.nodes.btn_refresh_title, "_refresh_quest")
		gui_lang.set_text_upper(self, self.nodes.btn_surrender_title, "_surrender")
		gui_input.set_disabled(self, self.btns[#self.btns], true)

		
		
	end

	gui_animate.show_bottom(self, self.nodes.wrap)
end

function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = self.id,
			visible = false,
		})
	end)
end

-- Отрсивока кнопок
function M.render_btns(self, data)
	self.type = data.type or "game"
	-- Добавляем первую линию кнопок 
	for i = 2, 12 do
		M.add_btn(self, i, 1)
	end

	-- Добавляем вторую линию кнопок 
	for i = 14, 24 do
		M.add_btn(self, i, 2)
	end

	-- Добавляем Третью линию кнопок 
	M.add_btn(self, 1, 3)
	for i = 25, 33 do
		M.add_btn(self, i, 3)
	end
	M.add_btn(self, 13, 3)

	self.focus_btn_id = nil

	-- Включаем нужные ноды
	--gui.set_enabled(self.nodes.wrap_btns, type == "game")
	--gui.set_enabled(self.nodes.btn_word, type == "game")
	--gui_loyouts.set_enabled(self, self.nodes.btn_surrender, self.type == "game")
	--gui_loyouts.set_enabled(self, self.nodes.btn_close, self.type == "input")
	gui_loyouts.set_enabled(self, self.nodes.btn_close, false)

	if self.type == "game" then
		-- кнопки внизу
		self.btns[#self.btns + 1] = {
			id = "word", 
			type = "btn", 
			section = "footer", 
			node = self.nodes.btn_word,
			node_title = self.nodes.btn_word_title,
			icon = "button_default_violet_",
			on_set_function = M.on_focus_btn,
		}
		self.btns[#self.btns + 1] = {
			id = "refresh", 
			type = "btn", 
			section = "footer", 
			node = self.nodes.btn_refresh,
			node_title = self.nodes.btn_refresh_title,
			icon = "button_default_violet_",
			on_set_function = M.on_focus_btn,
		}
		self.btns[#self.btns + 1] = {
			id = "surrender", 
			type = "btn", 
			section = "footer", 
			node = self.nodes.btn_surrender,
			node_title = self.nodes.btn_surrender_title,
			icon = "button_default_violet_",
			on_set_function = M.on_focus_btn,
		}

	else
		-- Добавляем кнопку закрытия
		--[[
		table.insert(self.btns, 1, {
			id = "close", 
			type = "btn", 
			section = "header", 
			node = self.nodes.btn_close,
			node_wrap = self.nodes.btn_close_icon,
			icon = "btn_circle_bg_red_",
			wrap_icon = "btn_icon_close_",
			on_set_function = M.on_focus_btn,
		})
		--]]

		-- Добавляем кнопку удаления текста
		self.btns[#self.btns + 1] = {
			id = "delete", 
			type = "btn", 
			section = "footer", 
			node = self.nodes.btn_word,
			node_title = self.nodes.btn_word_title,
			icon = "button_default_violet_",
			on_set_function = M.on_focus_btn,
		}

		-- Добавляем кнопку пробела
		self.btns[#self.btns + 1] = {
			id = "space", 
			type = "btn", 
			section = "footer", 
			node = self.nodes.btn_refresh,
			node_title = self.nodes.btn_refresh_title,
			icon = "button_default_violet_",
			on_set_function = M.on_focus_btn,
		}

		-- Добавляем кнопку пробела
		self.btns[#self.btns + 1] = {
			id = "close", 
			type = "btn", 
			section = "footer", 
			node = self.nodes.btn_surrender,
			node_title = self.nodes.btn_surrender_title,
			icon = "button_default_violet_",
			on_set_function = M.on_focus_btn,
		}
	end
end

-- Добавление кнопок с буквами
function M.add_btn(self, i, num_line)
	self.btns[#self.btns + 1] = {
		id = "keyboard_"..i, 
		type = "btn", 
		section = "line_"..num_line, 
		is_key = true,
		areol_name = "key_"..i.."_template/areol_template",
		node = gui.get_node("key_"..i.."_template/btn_wrap"),
		node_title = gui.get_node("key_"..i.."_template/btn_title"),
		icon = "button_default_violet_",
		on_set_function = M.on_focus_btn,
	}
end

function M.on_focus_btn(self, btn, focus)
	if focus and btn.disabled then
		-- Если кнопка заблокирована
		gui.set_alpha(btn.node, 1)
		gui.play_flipbook(btn.node, "button_gray_focus")
		gui.set_color(btn.node_title, color.red)

	end
end

-- Получение символа в кнопке
function M.get_symbol(btn)
	local str = utf8.lower(gui.get_text(btn.node_title))
	str = string.gsub(str, '^%s*(.-)%s*$', '%1')
	return str
end

-- Обработка результата нажатия
function M.result(self, btn, type)
	if type == 'success' then
		gui.play_flipbook(btn.node, "button_default_green_default")
	else
		gui.play_flipbook(btn.node, "button_default_red_default")
		msg.post("main:/sound", "play", {sound_id = "ovation_fail"})
		msg.post("main:/sound", "play", {sound_id = "response-error"})
	end
end


-- Нажатие на кнопку
function M.activate_btn(self, focus_btn_id)
	local btn = self.btns[focus_btn_id]

	if btn.disabled then
		return false
	end

	gui_animate.activate(self, btn.node, function_after)

	if btn.id == "word" then
		
		-- СЛово целиком
		msg.post("game-room:/core_game", "event", {
			id = "get_full_word"
		})

		msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	elseif btn.id == "close" then
		-- Закрытие
		msg.post("/loader_gui", "visible", {
			id = self.id,
			visible = false,
		})
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	elseif btn.id == "refresh" then
		-- Потвотрить вопрос
		msg.post("game-room:/core_game", "event", {
			id = "get_refresh_quest"
		})
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	elseif btn.id == "surrender" then
		-- Игрок сдаётся
		msg.post("game-room:/core_game", "event", {
			id = "surrender"
		})
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	elseif btn.id == "delete" then
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})
		msg.post("/loader_gui", "set_status", {
			id = "all",
			type = "input_keyboard",
			key = "delete_symbol",
			is_from_msg = true,
			from_id = self.id,
		})

	elseif btn.id == "space" then
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})
		msg.post("/loader_gui", "set_status", {
			id = "all",
			type = "input_keyboard",
			key = "space",
			is_from_msg = true,
			from_id = self.id,
		})

	elseif btn.id == "close" then
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})
		msg.post("/loader_gui", "set_status", {
			id = "all",
			type = "input_keyboard",
			key = "close",
			is_from_msg = true,
			from_id = self.id,
		})

	elseif btn.is_key and self.type == "input" then
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})

		msg.post("/loader_gui", "set_status", {
			id = "all",
			type = "input_keyboard",
			key = "set_symbol",
			is_from_msg = true,
			from_id = self.id,
			value = M.get_symbol(btn)
		})

	elseif btn.is_key then
		msg.post("main:/sound", "play", {sound_id = "activate_symbol"})
		gui_input.set_focus(self, nil)
		self.activate_btn = btn
		gui.play_flipbook(btn.node, "button_default_yellow_default")
		for i, item in ipairs(self.btns) do
			if btn.id ~= item.id then
				gui_input.set_disabled(self, item, true)
			end
		end
		gui.move_above(btn.node, gui.get_node(btn.areol_name..'/wrap'))
		self.areol_symbol = gui_animate.areol(self, btn.areol_name, speed_to_second, "loop", nil, 0.35)

		msg.post("main:/loader_gui", "visible", {
			id = "study",
			visible = false
		})

		msg.post("game-room:/core_game", "event", {id = "key_activate_symbol",value = {symbol = M.get_symbol(btn)}})
		--[[
		msg.post("/loader_gui", "set_status", {
			id = "all",
			type = "activate_key",
			is_from_msg = true,
			from_id = self.id,
			value = M.get_symbol(btn)
		})

		timer.delay(1, false, function (self)
			msg.post("/loader_gui", "set_status", {
				id = self.id,
				type = "result",
				value = {type = "success"}
			})
		end)
		--]]
	end
end

-- Показать курсор на кнопку
function M.study_touch(self)
	-- Смотрим какие закрыты буквы на табло
	for i, item in ipairs(storage_game.game.round.tablo) do
		if not item.open then
			local symbol = utf8.lower(item.symbol)

			for i, btn in ipairs(self.btns) do

				if btn.is_key and M.get_symbol(btn) == symbol then
					-- Палец нажимает в точку
					timer.delay(1, false, function (self)
						self.btn_touch_node = btn.node

						msg.post("main:/loader_gui", "set_status", {
							id = "study",
							type = "set_items",
							timeline = {
								{
									type = "touch",
									position_start = gui.get_screen_position(btn.node),
									position_end = gui.get_screen_position(btn.node)
								}
							}
						})
					end)

					break
				end
			end

			break
		end
	end
end

return M