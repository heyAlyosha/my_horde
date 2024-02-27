-- функции для интерфейса
local M = {}

local druid = require("druid.druid")
local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"
local core_player_function = require "main.core.core_player.modules.core_player_function"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_input = require "main.gui.modules.gui_input"
local gui_size = require "main.gui.modules.gui_size"
local color = require("color-lib.color")
local online_image = require "main.online.online_image"
local gui_animate = require "main.gui.modules.gui_animate"

M.level_text = 'ур.'
M.min_line = 0
M.max_line = -290

function M.init(self)
	
end

-- Записываем позиции для плашек баланса
function M.set_position_balance(self)
	self.druid = druid.new(self)

	-- Записываем позицию 
	storage_gui.interface = {
		position_coin_screen = gui.get_screen_position(self.nodes.coin_wrap),
		position_score_screen = gui.get_screen_position(self.nodes.score_wrap)
	}
end

-- Обновление Ававтарки
function M.update_avatar(self)
	-- Ававтарка
	if storage_player.avatar_url then
		local url = storage_player.avatar_url
		online_image.set_texture(self, self.nodes.avatar_img, url)
	end
end

-- Обновление баланса
function M.update_balance(self)
	local node_coin = self.nodes.coin
	local node_score = self.nodes.score
	local node_rating = self.nodes.rating
	local node_line = self.nodes.score_line
	local max_line = M.max_line

	gui_loyouts.set_text(self, node_coin, storage_player.coins)
	gui_loyouts.set_text(self, node_score, storage_player.score)
	gui_loyouts.set_text(self, node_rating, storage_player.rating or '0')

	self.current_values.coins = storage_player.coins
	self.current_values.rating = storage_player.rating

	-- Если изменились очки, обновляем линию опыта
	if storage_player.score ~= self.current_values.score then
		self.current_values.score = storage_player.score

		local score_player_data = core_player_function.get_level_data_user()
		local line_active = max_line * score_player_data.procent_to_next_level * 0.01

		if score_player_data.procent_to_next_level < 0 then
			line_active = 0
		end

		if line_active < -360 then
			line_active = -360
		elseif line_active > 360 then
			line_active = 360
		end

		gui_loyouts.set_fill_angle(self, node_line, line_active)

		if score_player_data.procent_to_next_level >= 100 then
			core_player_function.level_up(self)
		end
	end

	--
end

-- Обновление уровня
function M.update_level(self, level)
	local level = level or storage_player.level
	local node_level = self.nodes.account_level
	local level_text = M.level_text

	gui_loyouts.set_text(self, node_level, level_text .. ' ' .. level)
end

-- Обновление имени
function M.update_name(self)
	local node = self.nodes.user_name
	local node_wrap = self.nodes.user_name_wrap

	gui_loyouts.set_text(self, node, utf8.upper(storage_player.name))
	local margin = 10
	gui_size.set_gui_wrap_from_text(node, node_wrap, nil, margin, self)
end

-- Обновление кнопки громкости
function M.update_volume(self)
	local btn = self.btns_id.volume

	if storage_player.settings.volume_music > 0 or storage_player.settings.volume_effects > 0 then
		btn.color_icon = nil
	else
		btn.color_icon = color.darkred
	end

	gui_input.render_btns(self, self.btns)
end

-- Установка слоёв
function M.set_layer_account_wrap(self, layer)
	gui_loyouts.set_layer(self, self.nodes.account_wrap, layer)
	gui_loyouts.set_layer(self, self.nodes.avatar_wrap, layer)
	gui_loyouts.set_layer(self, gui.get_node("areol_template/wrap"), layer)
	gui_loyouts.set_layer(self, gui.get_node("areol_template/areol_big"), layer)
	gui_loyouts.set_layer(self, gui.get_node("areol_template/areol_mini"), layer)
	gui_loyouts.set_layer(self, gui.get_node("avatar_border"), layer)
	gui_loyouts.set_layer(self, gui.get_node("avatar_border_bg"), layer)
	gui_loyouts.set_layer(self, gui.get_node("avatar_img"), layer)
	gui_loyouts.set_layer(self, gui.get_node("avatar_line"), layer)
	gui_loyouts.set_layer(self, gui.get_node("avatar_line_active"), layer)
	gui_loyouts.set_layer(self, gui.get_node("account_level"), layer)
	gui_loyouts.set_layer(self, gui.get_node("account_name_bg"), layer)
	gui_loyouts.set_layer(self, gui.get_node("account_name"), layer)
end

function M.set_layer_score(self, layer)
	gui_loyouts.set_layer(self, gui.get_node("score_template/wrap"), layer)
	gui_loyouts.set_layer(self, gui.get_node("score_template/icon"), layer)
	gui_loyouts.set_layer(self, gui.get_node("score_template/number"), layer)
end

function M.set_layer_stars(self, layer)
	gui_loyouts.set_layer(self, gui.get_node("stars"), layer)
	gui_loyouts.set_layer(self, gui.get_node("stars_body"), layer)
	gui_loyouts.set_layer(self, gui.get_node("wrap_stars"), layer)
	gui_loyouts.set_layer(self, gui.get_node("star_1"), layer)
	gui_loyouts.set_layer(self, gui.get_node("star_2"), layer)
	gui_loyouts.set_layer(self, gui.get_node("star_3"), layer)
	gui_loyouts.set_layer(self, gui.get_node("wrap_list"), layer)

	for i = 1, 3 do
		gui_loyouts.set_layer(self, gui.get_node("list_item_"..i.."_template/wrap"), layer)
		gui_loyouts.set_layer(self, gui.get_node("list_item_"..i.."_template/icon"), layer)
		gui_loyouts.set_layer(self, gui.get_node("list_item_"..i.."_template/content"), layer)
	end
	
end

-- Обновление кнопки громкости
function M.study(self, id)
	gui.set_render_order(storage_gui.orders.interface)
	gui_loyouts.set_enabled(self, self.nodes.study_bg, false)

	local layer = "box"
	M.set_layer_account_wrap(self, layer)
	M.set_layer_score(self, layer)
	M.set_layer_stars(self, layer)

	gui.cancel_animation(self.nodes.score_line, "fill_angle")

	if self.last_angle and id ~= "level_up" then
		gui_loyouts.set_fill_angle(self, self.nodes.score_line, self.last_angle)
		self.last_angle = nil
	end

	if self.areol_level then
		self.areol_level.stop(self)
		self.areol_level = nil
	end

	if self.study_pulse then
		self.study_pulse.stop(self)
		self.study_pulse = nil
	end

	if self.study_pulse_line then
		self.study_pulse_line.stop(self)
		self.study_pulse_line = nil
	end

	if id == "line" then
		gui.set_render_order(13)
		gui_loyouts.set_enabled(self, self.nodes.study_bg, true)

		gui_loyouts.set_layer(self, self.nodes.score_line, "study_focus")

		self.last_angle = gui.get_fill_angle(self.nodes.score_line)
		gui_loyouts.set_fill_angle(self, self.nodes.score_line, M.min_line)
		local line_active = M.max_line * 100 * 0.01
		gui.animate(self.nodes.score_line, 'fill_angle', line_active, gui.EASING_LINEAR, 5)

		local delay = 1
		self.study_pulse = gui_animate.pulse_loop(self, self.nodes.score_line, delay)

	elseif id == "xp_and_line" then
		gui.set_render_order(13)
		gui_loyouts.set_enabled(self, self.nodes.study_bg, true)

		gui_loyouts.set_layer(self, self.nodes.score_line, "study_focus")

		self.last_angle = gui.get_fill_angle(self.nodes.score_line)
		gui_loyouts.set_fill_angle(self, self.nodes.score_line, M.min_line)
		local line_active = M.max_line * 100 * 0.01
		gui.animate(self.nodes.score_line, 'fill_angle', line_active, gui.EASING_LINEAR, 5)

		
		local delay = 1
		self.study_pulse_line = gui_animate.pulse_loop(self, self.nodes.score_line, delay)

		gui_loyouts.set_enabled(self, self.nodes.study_bg, true)

		local layer = "study_focus"
		M.set_layer_score(self, layer)

		local delay = 1
		self.study_pulse = gui_animate.pulse_loop(self, gui.get_node("score_template/wrap"), delay)

	elseif id == "level_up" then
		gui.set_render_order(13)
		gui_loyouts.set_enabled(self, self.nodes.study_bg, true)

		local layer = "study_focus"
		M.set_layer_account_wrap(self, layer)

		-- Анимация появления ареола вокруг плашки
		local name_template = 'areol_template'
		local speed_to_second = 90
		local duration = "loop"
		if self.areol_level then
			self.areol_level.stop(self)
			self.areol_level = nil
		end
		self.areol_level = gui_animate.areol(self, name_template, speed_to_second, duration, function_end, scale)

	elseif id == "xp" then
		gui.set_render_order(13)
		gui_loyouts.set_enabled(self, self.nodes.study_bg, true)

		local layer = "study_focus"
		M.set_layer_score(self, layer)

		local delay = 1
		self.study_pulse = gui_animate.pulse_loop(self, gui.get_node("score_template/wrap"), delay)

	elseif id == "stars" then
		gui.set_render_order(13)
		gui_loyouts.set_enabled(self, self.nodes.study_bg, true)

		local layer = "study_focus"
		M.set_layer_stars(self, layer)

		local delay = 2
		self.study_pulse = gui_animate.pulse_loop(self, gui.get_node("stars"), delay)
	end

end

return M