-- Фнкции
local M = {}

-- Добавление атакующего зомбика
function M.add_zombie_attack(self, horde_index, position, target)
	local item = self.horde[horde_index]
	local position = position or go.get_position(item.url)

	print("add_zombie_attack", target)

	if item then
		-- Удаляем зомбика из орды
		table.remove(self.horde, horde_index)
		go.delete(item.url)

		local properties = {
			command = self.command,
			skin_id = item.skin_id,
			human_id = item.human_id,
			parent = self.parent,
			target = target
		}
		pprint("factory", factory.create("#zombie_factory", position, rotation, properties))
	end
end

return M