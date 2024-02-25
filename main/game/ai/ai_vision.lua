-- Зрение ботов
local M = {}

-- Статический объект
function M.add_static_object(self, group_name)
	local group_id
	if not storage_game.groups_aabbcc[group_name] then
		group_id = aabb.new_group()
		storage_game.groups_aabbcc[group_name] = {
			id = group_id,
			command = self.command,
			objects = {}
		}
	else
		group_id = storage_game.groups_aabbcc[group_name].id
	end

	self.pos = go.get_position(".")
	self.size = go.get("#object", "size")

	local aabb_id = aabb.insert(group_id, self.pos.x , self.pos.y, self.size.x, self.size.y)

	print("add_static_object",group_id, aabb_id)
	storage_game.groups_aabbcc[group_name].objects[aabb_id] = {
		url = msg.url(go.get_id()),
		command = self.command
	}

	return group_id, aabb_id
end

-- Перемещающийся объект
function M.add_dynamic_object(self, group_name)
	local group_id
	if not storage_game.groups_aabbcc[group_name] then
		group_id = aabb.new_group()
		storage_game.groups_aabbcc[group_name] = {
			id = group_id,
			objects = {}
		}
	else
		group_id = storage_game.groups_aabbcc[group_name].id
	end

	local go_url = msg.url(go.get_id())
	self.size = go.get("#body", "size")
	local aabb_id = aabb.insert_gameobject(group_id, go_url, self.size.x, self.size.y)

	storage_game.groups_aabbcc[group_name].objects[aabb_id] = {
		url = msg.url(go.get_id()),
		command = self.command
	}

	print("add_dynamic_object",group_id, aabb_id)

	return group_id, aabb_id
end

-- ВИдимые объекты
function M.get_visible(self, exclude_aabb_id, distantion)
	local position = go.get_position()
	local width = distantion * 2
	local height = distantion * 2
	local group_id = storage_game.groups_aabbcc.visible_object.id
	local result, count = aabb.query(group_id, position.x, position.y, width, height)

	local objects = {}

	for i = 1, #result do
		local aabb_id = result[i]
		if exclude_aabb_id ~= aabb_id then
			local visible_object = storage_game.groups_aabbcc.visible_object.objects[aabb_id]
			local url = visible_object.url
			if self.command ~= visible_object.command then
				local target =  storage_game.go_targets[go_controller.url_to_key(url)]
				local add_item = {
					url = url, sort = target.target_useful - target.target_current
				}
				objects[#objects + 1] = add_item
			end
		end
	end

	if #objects > 0 then
		table.sort(objects, function (a,b)
			return a.sort > b.sort
		end)
		return objects
	else
		return false
	end
end

return M