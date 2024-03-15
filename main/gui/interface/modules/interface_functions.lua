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
		position_coins_screen = gui.get_screen_position(self.nodes.coin_wrap),
		position_xp_screen = gui.get_screen_position(self.nodes.xp_wrap),
		position_resource_screen = gui.get_screen_position(self.nodes.resource_wrap),
		position_score_screen = gui.get_screen_position(self.nodes.score),
		position_star_screen = gui.get_screen_position(self.nodes.stars_wrap),
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
	local node_xp = self.nodes.xp
	local node_resource = self.nodes.resource
	local node_score = self.nodes.score

	gui_loyouts.set_text(self, node_coin, storage_player.coins)
	gui_loyouts.set_text(self, node_xp, storage_player.xp)
	gui_loyouts.set_text(self, node_resource, storage_player.resource)
	gui_loyouts.set_text(self, node_score, storage_player.score)

	self.current_values.coins = storage_player.coins
	self.current_values.rating = storage_player.rating
end

-- Обновление имени
function M.update_name(self)
	local node = self.nodes.user_name
	local node_wrap = self.nodes.user_name_wrap

	gui_loyouts.set_text(self, node, utf8.upper(storage_player.name))
	local margin = 4
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

-- Запись направления
function M.set_dir_goal(self, dir_goal)
	if self.dir_goal ~= dir_goal then
		if dir_goal then
			local angle = math.atan2(dir_goal.y, dir_goal.x)    -- [1]
			local rot = vmath.quat_rotation_z(angle)
			gui.set_rotation(self.nodes.marker_wrap, rot)
			gui.set_enabled(self.nodes.marker_wrap, true)

			if not self.dir_goal_pulse then
				self.dir_goal_pulse = true
				gui.animate(self.nodes.marker_goal, "position.x", 118, gui.EASING_INOUTCUBIC, 1, 0, handle, gui.PLAYBACK_LOOP_PINGPONG)
			end
		else
			gui.set_enabled(self.nodes.marker_wrap, false)
		end
	end

	self.dir_goal = dir_goal
end

return M