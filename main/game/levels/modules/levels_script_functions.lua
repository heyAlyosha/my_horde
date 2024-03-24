-- Скрипты 
local M = {}

-- Добавление целей для разрушения
function M.add_goal_ruins(self, objects, handle_success)
	if self.goal_ruins then
		-- Удаляем старые цели
		for k, item in pairs(self.goal_ruins) do
			M.delete_goal(self, "goal_ruins", k)
		end
	end

	-- Создаём цели
	self.goal_ruins = {}
	for i, url_object in ipairs(objects) do
		if go_controller.is_object(url_object) then
			self.goal_ruins[go_controller.url_to_key(url_object)] = {
				id = url_object,
				urls = collectionfactory.create("#goal_collectionfactory", go.get_position(url_object)),
			}
		end
	end

	self.goal_ruins_handle = handle_success
end

-- Следим за целями для уничтожения
function M.on_update(self)
	-- Расстояние до цели для отображения направления
	local view_dist_goal = 240
	-- Есть цели для уничтожения
	if self.goal_ruins then
		-- Обрабатываем цели
		local index = 0
		local position_player = go.get_position("player")

		for k, item in pairs(self.goal_ruins) do
			-- Есть ли объект прицеливания
			if go_controller.is_object(item.id) then
				-- Обновляем позицию
				local position_object = go.get_position(item.id)
				go.set_position(position_object, item.urls[hash("/marker_goal")])
				index = index + 1

				-- Расстояние до цели, чтобы показать указатель на неё
				self.dir_goal = position_object - position_player
				if vmath.length(self.dir_goal) > view_dist_goal then
					self.dir_goal = vmath.normalize(self.dir_goal)
				else
					self.dir_goal = nil
				end

			else
				-- Удаляем цель, если объекта нет
				M.delete_goal(self, "goal_ruins", k)
			end
		end

		if index == 0 then
			--целей це осталось
			if self.goal_ruins_handle then
				self.goal_ruins_handle(self)
			end
			self.goal_ruins = nil
		end

		--если изменилось направление указателя цели
		if self.dir_goal ~= self.last_dir_goal and storage_gui.components_visible.interface then
			msg.post(storage_gui.components_visible.interface, "set_content", {type = "set_dir_goal", dir_goal = self.dir_goal})
		end

		self.last_dir_goal = self.dir_goal
		
	end
end

-- Добавление цели
--[[
function M.add_goal(self, type_goal, key)
	if self[type_goal] and self[type_goal][key] then
		for goal_k, goal_item in pairs(self[type_goal][key].urls) do
			go.delete(goal_item)
		end
		self[type_goal][key] = nil
	end
end
--]]

-- Удаление цели
function M.delete_goal(self, type_goal, key)
	if self[type_goal] and self[type_goal][key] then
		for goal_k, goal_item in pairs(self[type_goal][key].urls) do
			go.delete(goal_item)
		end
		self[type_goal][key] = nil
	end
end

-- Перемещение 
function M.human_position_to(self, position_to, human_id, animation_id)
	
end

return M