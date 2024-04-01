-- Сражение между ордами c дракой
local M = {}

-- Начало сражения
function M.start(self, enemy)
	local url_enemy_script = go_controller.url_script(enemy)
	local enemy_attack_horde = go.get(url_enemy_script, "attack_horde")
	if not enemy_attack_horde then
		msg.post(enemy, "set_attack_horde", {attack_horde = true})
	end

	if not self.attack_horde then
		msg.post(".", "set_attack_horde", {attack_horde = true})
	end
end

return M