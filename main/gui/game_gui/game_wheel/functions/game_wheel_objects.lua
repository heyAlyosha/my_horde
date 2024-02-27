-- Функции для работы с объектами
local M = {}

local game_content_artifact = require "main.game.content.game_content_artifact"
local gui_animate = require "main.gui.modules.gui_animate"
local game_content_wheel = require "main.game.content.game_content_wheel"
local game_wheel_functions = require "main.gui.game_gui.game_wheel.functions.game_wheel_functions"
local color = require("color-lib.color")

-- Обновление объектов на барабане
function M.update(self)
	-- Объекты
	self.objects = self.objects or {}
	
	-- Сектора
	self.sectors = self.sectors or {}

	for i, sector in ipairs(self.sectors) do
		-- Если в этом секторе стоит артефакт
		if sector.artifact or (sector.preview and sector.preview.artifact) then
			local artifact = sector.artifact or sector.preview.artifact
			local preview = sector.preview and sector.preview.artifact

			-- Создаём ноду под артефакт, если её нет
			if not sector.nodes.artifact then
				sector.nodes.artifact = gui.clone(self.nodes.object)
				gui.set_enabled(sector.nodes.artifact, true)
			end

			-- Отрисовываем иконку предмета
			gui.set_texture(sector.nodes.artifact, "objects_mini")
			gui.play_flipbook(sector.nodes.artifact, artifact.icon)

			--self.add_scale_artifact = self.add_scale_artifact or 1.5
			local add_scale_artifact = gui.get_scale(gui.get_node("object")).x
			gui.set_scale(sector.nodes.artifact, vmath.vector3(artifact.scale) * add_scale_artifact)
			self.objects[sector.id] = sector

			-- Цвет плашки под ним
			local color_object = vmath.vector4(color[artifact.color].x, color[artifact.color].y, color[artifact.color].z, 0.9)
			gui.set_color(sector.nodes.object, color_object)

			-- Если превью, делаем объект прозрачным
			if preview then
				gui.set_alpha(sector.nodes.artifact, 0.9)
				gui.animate(sector.nodes.artifact, 'scale', artifact.scale * self.add_scale_artifact * 1.25, gui.EASING_INOUTSINE, 0.00001)
			end

		elseif not sector.artifact and sector.nodes.artifact  then
			-- Если артефакта нет, но осталась старая нода от него
			gui.delete_node(sector.nodes.artifact)
			-- Цвет плашки под ним
			local color_object = vmath.vector4(color.black.x, color.black.y, color.black.z, 0.3)
			gui.set_color(sector.nodes.object, color_object)
			sector.nodes.artifact = nil

			self.objects[sector.id] = nil

		end
	end
end

-- Отрисовка всех объектов
function M.render_all(self)
	for id, sector in pairs(self.objects) do
		M.render_item(self, sector)
	end

	M.update(self)
end

-- Отрисовка всех объектов
function M.scale_all(self, duration, scale)
	self.add_scale_artifact = scale.x
	for id, sector in pairs(self.objects) do
		if sector.artifact or (sector.preview and sector.preview.artifact) then
			local artifact = sector.artifact or sector.preview.artifact
			artifact.original_scale = artifact.original_scale or artifact.scale
			artifact.scale = artifact.original_scale * scale.x

			if sector.nodes.artifact then
				artifact.add_scale = scale.x
				--M.render_item(self, sector)
				--[[
				gui.animate(sector.nodes.artifact, 'scale', artifact.scale * scale, gui.EASING_INOUTSINE, duration, 0, function (self)
					--M.render_item(self, sector)
				end)
				--]]
			end
		end

	end
	--gui.animate(self.nodes.wrap_objects, 'scale', scale, gui.EASING_INOUTSINE, duration)

end

-- Отрисовка отдельного объекта на секторе
function M.render_item(self, sector)
	local preview = sector.preview or {}
	if not sector.artifact and not preview.artifact then 
		return false

	else
		if not sector.nodes.object_icon then
			return false
		end

		local artifact = sector.artifact or sector.preview.artifact
		local screen_pos = gui.get_screen_position(sector.nodes.object_icon)
		local screen_pos_local =  gui.screen_to_local(sector.nodes.artifact, screen_pos)
		screen_pos_local.y = screen_pos_local.y - 10
		gui.set_position(sector.nodes.artifact, screen_pos_local)

		-- Отрисовываем перспективу
		local max_y = 600
		local min_y = 130
		local sector_layer_height = 40

		local y = screen_pos_local.y - min_y
		local layer_sector = math.floor(y / sector_layer_height)

		if layer_sector < 0 then
			layer_sector = 0

		elseif layer_sector > 30 then
			layer_sector = 30

		end

		if sector.artifact and sector.artifact.layer_sector ~= layer_sector then
			local name_layer = "objects_" .. layer_sector
			gui.set_layer(sector.nodes.artifact, name_layer)
			sector.artifact.layer_sector = layer_sector
		end

	end
end

-- Отрисовка анимаций превьюшек для захвата секторов
function M.render_preview_object(self, sector_id, artifact_id, player_id)
	self.active_buff = false

	if self.timer_preview_object then
		timer.cancel(self.timer_preview_object)
		self.timer_preview_object = nil
	end

	msg.post("/loader_gui", "set_status", {
		id = "game_wheel",
		type = "preview_aim",
		visible = false
	})

	if not artifact_id then
		self.sound_catch_count = 0
		return
	end

	local sector = self.sectors[sector_id]
	local artifact = game_content_artifact.get_item(artifact_id, player_id, is_game, is_reward)

	if artifact_id == self.preview_artifact_id then
		--return
	end

	self.preview_artifact_id = artifact_id

	if artifact.type ~= "catch" then
		self.sound_catch_count = 0
	end

	if artifact.type == "accuracy" then
		-- Точность
		local start_size = game_content_wheel.get_size_aim(self, player_id)
		local start_speed = game_content_wheel.get_speed_aim(self, player_id)

		function activate(self)
			msg.post("main:/sound", "play", {sound_id = "game_result_open"})
			game_wheel_functions.ray_object(self, sector, color[artifact.color], function_end)
			msg.post("/loader_gui", "set_status", {
				id = "game_wheel",
				type = "preview_aim",
				value = {
					speed = start_speed, 
					size = game_content_wheel.get_size_aim(self, player_id, artifact.accuracy)
				},
				visible = true
			})
		end

		activate(self)

	elseif artifact.type == "speed_caret" then
		-- Точность
		local start_size = game_content_wheel.get_size_aim(self, player_id)
		local start_speed = game_content_wheel.get_speed_aim(self, player_id)

		function activate(self)
			msg.post("main:/sound", "play", {sound_id = "game_result_open"})
			game_wheel_functions.ray_object(self, sector, color[artifact.color], function_end)
			msg.post("/loader_gui", "set_status", {
				id = "game_wheel",
				type = "preview_aim",
				value = {
					speed = game_content_wheel.get_speed_aim(self, player_id, artifact.speed_caret), 
					size = start_size
				},
				visible = true
			})
		end

		activate(self)

	elseif artifact.type == "bank" or artifact.type == "catch" or artifact.type == "trap" then

		if self.sound_catch_count == 0 then
			msg.post("main:/sound", "play", {sound_id = "game_result_open"})
		end

		self.sound_catch_count = self.sound_catch_count + 1

		game_wheel_functions.ray_object(self, sector, color[artifact.color], function_end)
		--[[

		timer.delay(0.25, false, function (self)
			msg.post("game-room:/core_game", "event", {
				id = "get_transfer",
				type = "sector_preview",
				count = artifact.score,
				player_id = "player",
				player_from_id = "",
				player_to_id = "",
				sector_id = sector_id
			})
		end)
		--]]

	else

	end
end

return M