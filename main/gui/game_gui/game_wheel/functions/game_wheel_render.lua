-- Функции
local M = {}

local gui_catalog = require "main.gui.modules.gui_catalog"
local storage_game = require "main.game.storage.storage_game"
local gui_input = require "main.gui.modules.gui_input"
local gui_text = require "main.gui.modules.gui_text"
local game_content_artifact = require "main.game.content.game_content_artifact"
local gui_animate = require "main.gui.modules.gui_animate"
local game_content_wheel = require "main.game.content.game_content_wheel"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local game_wheel_functions = require "main.gui.game_gui.game_wheel.functions.game_wheel_functions"
local game_wheel_objects = require "main.gui.game_gui.game_wheel.functions.game_wheel_objects"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local color = require("color-lib.color")
local gui_scale = require "main.gui.modules.gui_scale"

-- Отрисовка колеса
function M.start(self)
	-- Удаляем старые ноды
	if self.sectors then
		for i, sector in ipairs(self.sectors) do
			if sector.nodes then
				for k, node_delete in pairs(sector.nodes) do
					gui.delete_node(node_delete)
					sector.nodes[k] = nil

				end
			end
		end
	end

	

	-- Сектора
	self.sectors = game_content_wheel.get_all(self)
	--[[
	if self.sectors then
		local sectors = game_content_wheel.get_all(self)
		for i = 1, #sectors do
			if self.sectors[i] then
				sectors[i].nodes = self.sectors[i].nodes
				sectors[i].artifact = self.sectors[i].artifact
				sectors[i].preview = self.sectors[i].preview
			end
			pprint(self.sectors[i])
		end
		
		self.sectors = sectors
	else
		self.sectors = game_content_wheel.get_all(self)
	end
	]]--

	-- Находим угол сектора
	self.angle_sector = 360 / #self.sectors

	-- Прячем ноду для клонирования
	gui.set_enabled(self.nodes.sector_for_clone, false)
	gui.set_enabled(self.nodes.object, false)

	-- Отрисовываем
	local start_rotation = 0

	for i, sector in ipairs(self.sectors) do
		-- Клонируем
		if not sector.nodes then
			
		end

		local node_clones = gui.clone_tree(self.nodes.sector_for_clone)
		sector.nodes = {
			wrap = node_clones[hash("sector_template/wrap")],
			wrap_content = node_clones[hash("sector_template/wrap_content")],
			object_icon = node_clones[hash("sector_template/object_icon")],
			value = node_clones[hash("sector_template/value")],
			sector_icon = node_clones[hash("sector_template/sector_icon")],
			object = node_clones[hash("sector_template/object")],
		}

		-- Включаем сектор
		gui.set_enabled(sector.nodes.wrap, true)
		-- Поворачиваем его
		local rotation_wrap = gui.get_rotation(sector.nodes.wrap)
		rotation_wrap.z = start_rotation
		gui.set_rotation(sector.nodes.wrap, rotation_wrap)
		-- контент внутри него
		local rotation_wrap_content = gui.get_rotation(sector.nodes.wrap_content)
		rotation_wrap_content.z = self.angle_sector/2
		gui.set_rotation(sector.nodes.wrap_content, rotation_wrap_content)
		-- Размер сектора
		gui.set_fill_angle(sector.nodes.wrap, self.angle_sector)
		-- Середина сектора
		sector.center = rotation_wrap.z - self.angle_sector/2

		start_rotation = start_rotation + self.angle_sector

		M.item(self, sector)

	end

	M.aim(self, player)
	game_wheel_functions.rotate_aim(self, 1)
	M.table(self)

	game_wheel_objects.update(self)
	timer.delay(0.05, false, function (self)
		game_wheel_objects.render_all(self)
	end)

	game_wheel_functions.set_screen_position(self)
	storage_game.possible_aim_sectors = game_wheel_functions.get_sectors_aim(self, 90, 270)
end

-- Отрисовка отдельного сектора
function M.item(self, sector)
	-- Цвет сектора
	if sector.preview and not sector.catch then
		gui.set_color(sector.nodes.wrap, sector.preview.color)
	else
		gui.set_color(sector.nodes.wrap, sector.color)
	end

	-- Отрисовываем контент
	gui.set_enabled(sector.nodes.sector_icon, sector.type ~= "default")
	gui.set_enabled(sector.nodes.value, sector.type == "default")

	if sector.type == "default" then
		gui.set_text(sector.nodes.value, sector.value.score)

	else
		gui.play_flipbook(sector.nodes.sector_icon, sector.value.icon)

	end
end

-- Рендер превьюшки поставленного объекта
function M.preview(self, visible, artifact_id, player_id, sector_id)
	-- Удаляем все старые превьюшки
	for i = 1, #self.sectors do
		self.sectors[i].preview = nil
	end

	print("M.preview", visible)

	-- Добавляем превьюшки
	if visible then
		-- Отрисовываем ячейки
		game_wheel_functions.catch(self, sector_id, player_id, artifact_id, function (self, sector, player, artifact)
			if artifact and artifact.type ~= "try" then
				sector.preview = {
					color = player.color,
				}

				if sector.id == sector_id then
					sector.preview.artifact = artifact
				end

				game_wheel_objects.render_preview_object(self, sector_id, artifact_id, player_id)
			end
		end)
	else
		self.preview_artifact_id = nil
		game_wheel_objects.render_preview_object(self, sector_id, false, player_id)
	end

	M.update_sectors(self)
	game_wheel_objects.update(self)
	game_wheel_objects.render_all(self)
end

-- Рендер превьюшки поставленного объекта
function M.preview_aim(self, speed, size)
	-- УСтанавливаем размер прицела
	M.aim(self, player_id, size)

	-- Крутим каретку
	function change_scale(self, procent)
		game_wheel_functions.rotate_aim(self, procent)
		--pprint(procent)
	end

	-- Остановка каретки
	function stop_scale(self, procent)
		return
	end
	--pprint(speed)

	if self.animation_caret_preview then
		self.animation_caret_preview.stop(self)
		self.animation_caret_preview = nil
	end

	self.animation_caret_preview = gui_scale.start(self, "scale_template", speed, change_scale, stop_scale)
end

-- Обновляем все сектора
function M.update_sectors(self)
	for i = 1, #self.sectors do
		M.item(self, self.sectors[i])
	end

	storage_game.possible_aim_sectors = game_wheel_functions.get_sectors_aim(self, 90, 270)
end

-- Отрисовка прицела
function M.aim(self, player_id, size)
	local player = player or {}
	player_id = player_id or "player"
	
	-- Высчитываем текущий размер прицела
	if size then
		self.current_rotate = size
	else
		self.current_rotate = game_content_wheel.get_size_aim(self, player_id)
	end

	-- Отрисовываем
	gui_loyouts.set_fill_angle(self, self.nodes.aim, self.current_rotate)

end

-- Табло
function M.table(self)
	local sector = game_wheel_functions.get_sector(self)
	if self.last_table_id ~= sector.id then
		if self.not_first_render then
			msg.post("main:/sound", "play", {sound_id = "nav_click_2", is_single = true})
		end

		self.not_first_render = true

		local text, color_text
		if sector.type == "default" then
			color_text = color.white
			text = gui_text.set_placeholder("{{score}} очков", {score = sector.value.score}) 
			--gui_text.set_text_formatted(self, self.nodes.table_text, text)

		elseif sector.type == "x2" then
			color_text = color.lime
			text = "Удвоение опыта!" 
			--gui_text.set_text_formatted(self, self.nodes.table_text, text)

		elseif sector.type == "open_symbol" then
			color_text = color.lime
			text = "Любая буква!" 
			--gui_text.set_text_formatted(self, self.nodes.table_text, text)

		elseif sector.type == "bankrot" then
			color_text = color.red
			text = "Бакрот!" 
			--gui_text.set_text_formatted(self, self.nodes.table_text, text)

		elseif sector.type == "skip" then
			color_text = color.red
			text = "Пропуск хода!" 
			--gui_text.set_text_formatted(self, self.nodes.table_text, text)

		end

		gui_loyouts.set_color(self, self.nodes.table_text, color_text)
		gui_loyouts.set_druid_text(self, self.nodes.table_text, utf8.upper(text))
		self.last_table_id = sector.id
	end
end

-- Перезагрузка барабана
function M.reset(self, sectors)
	local sectors = sectors or {}
	self.objects = {}

	storage_game.wheel = sectors
	M.start(self)
end


function M.layout_changed(self, message)
	if self.last_focus_wheel then

		local orientation
		if message.id == hash("Portrait") then
			orientation = "vertical"

		else
			orientation = "horisontal"

		end

		game_wheel_functions.focus_wheel(self, self.last_focus_wheel.visible, self.last_focus_wheel.type, game_wheel_objects, orientation, function (self)
			game_wheel_objects.update(self)
			timer.delay(0.05, false, function (self)
				game_wheel_objects.render_all(self)
			end)
		end)
	end

	--game_wheel_objects.update(self)
	M.start(self)
	M.study(self, self.study_id)
end

-- Для обучение
function M.study(self, id)
	self.study_id = id
	gui_loyouts.set_enabled(self, self.nodes.wheel_wrap_study, false)
	gui_loyouts.set_alpha(self, self.nodes.aim, 0.5)

	-- Прячем сектора под затемнение
	for i, item in ipairs(self.sectors) do
		gui_loyouts.set_layer(self,item.nodes.wrap, "box")
		gui_loyouts.set_layer(self,item.nodes.wrap_content, "box")
		gui_loyouts.set_layer(self,item.nodes.object, "box")
		gui_loyouts.set_layer(self,item.nodes.sector_icon, "box")
		gui_loyouts.set_layer(self,item.nodes.value, "")
	end

	-- Прячем прицел
	gui_loyouts.set_layer(self,self.nodes.wheel_wrap_study, "box")

	if id == "aim" then
		-- Выделяем прицел
		gui_loyouts.set_enabled(self, self.nodes.wheel_wrap_study, true)
		gui_loyouts.set_layer(self,self.nodes.aim, "focus_box")
		gui_loyouts.set_alpha(self, self.nodes.aim, 1)

	elseif  id == "sector_many_score" then
		-- Выделяем много очков
		gui_loyouts.set_enabled(self, self.nodes.wheel_wrap_study, true)
		gui_loyouts.set_layer(self,self.nodes.aim, "focus_box")

		for i, item in ipairs(self.sectors) do
			if item.type == "default" and item.value.score > 100 then
				gui_loyouts.set_layer(self,item.nodes.wrap, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.wrap_content, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.object, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.sector_icon, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.value, "focus_text")
			end
		end

	elseif id == "sector_green" then
		-- Выделяем много очков
		gui_loyouts.set_enabled(self, self.nodes.wheel_wrap_study, true)
		gui_loyouts.set_layer(self,self.nodes.aim, "focus_box")

		for i, item in ipairs(self.sectors) do
			if item.type == "open_symbol" or item.type == "x2" then
				gui_loyouts.set_layer(self,item.nodes.wrap, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.wrap_content, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.object, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.sector_icon, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.value, "focus_text")
			end
		end

	elseif id == "sector_red" then
		-- Выделяем много очков
		gui_loyouts.set_enabled(self, self.nodes.wheel_wrap_study, true)
		gui_loyouts.set_layer(self,self.nodes.aim, "focus_box")

		for i, item in ipairs(self.sectors) do
			if item.type == "bankrot" or item.type == "skip" then
				gui_loyouts.set_layer(self,item.nodes.wrap, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.wrap_content, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.object, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.sector_icon, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.value, "focus_text")
			end
		end

	elseif id == "trap" then
		-- Выделяем много очков
		gui_loyouts.set_enabled(self, self.nodes.wheel_wrap_study, true)
		gui_loyouts.set_layer(self,self.nodes.aim, "focus_box")

		for i, item in ipairs(self.sectors) do
			if item.artifact and item.artifact.type == "trap" and item.player and item.player.player_id ~= "player" then
				gui_loyouts.set_layer(self,item.nodes.wrap, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.wrap_content, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.object, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.sector_icon, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.value, "focus_text")
			end
		end

	elseif id == "catch" then
		-- Выделяем много очков
		gui_loyouts.set_enabled(self, self.nodes.wheel_wrap_study, true)
		gui_loyouts.set_layer(self,self.nodes.aim, "focus_box")

		for i, item in ipairs(self.sectors) do
			if item.catch and ((item.artifact and item.artifact.type == "catch") or not item.catch.artifact_id) and item.player and item.player.player_id ~= "player" then
				gui_loyouts.set_layer(self,item.nodes.wrap, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.wrap_content, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.object, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.sector_icon, "focus_box")
				gui_loyouts.set_layer(self,item.nodes.value, "focus_text")
			end
		end
	end
end

return M