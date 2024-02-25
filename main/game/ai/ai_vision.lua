-- Зрение ботов
local M = {}

-- Статический объект
function M.add_static_object(self, group_id)
	if not storage_game.groups_aabbcc[group_id] then
		storage_game.groups_aabbcc[group_id] =  aabb.new_group()
		group_id = storage_game.groups_aabbcc[group_id]
	else
		group_id = storage_game.groups_aabbcc[group_id]
	end

	self.pos = go.get_position(".")
	self.size = go.get("#object", "size")
	self.group_id = aabb.new_group()

	return group_id, aabb.insert(group_id, self.pos.x , self.pos.y, self.size.x, self.size.y)
end

-- Перемещающийся объект
function M.add_dynamic_object(self, group_id)
	if not storage_game.groups_aabbcc[group_id] then
		storage_game.groups_aabbcc[group_id] =  aabb.new_group()
		group_id = storage_game.groups_aabbcc[group_id]
	else
		group_id = storage_game.groups_aabbcc[group_id]
	end

	local go_url = msg.url(go.get_id())
	self.size = go.get("#body", "size")
	return group_id, aabb.insert_gameobject(group_id, go_url, self.size.x, self.size.y)
end

return M