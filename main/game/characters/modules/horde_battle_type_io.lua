-- Сражение между ордами типа IO
local M = {}

-- Начало сражения
function M.start(self, enemy, enemy_zone_infection)
	local url_enemy_script = go_controller.url_script(enemy)
	local size_horde_enemy = go.get(url_enemy_script, "size_horde")

	if size_horde_enemy > self.size_horde then
		local position = go.get_position()
		local options_raycast = {all = true}
		-- Смотрим какие зомбики попадают под 
		for i, zombie_horde in ipairs(self.horde) do
			-- Если зомбик не мёртв
			if not zombie_horde.is_death then
				local raycasts = physics.raycast(position, go.get_position(zombie_horde.url), {hash("infection_zoneqq")}, options)
			end
		end
	end
end

return M