-- Модуль для зоны инфекции орды (для карты)
local M = {}

function M.create(self)
	if not self.zone_infection then
		local properties = {
			parent = msg.url()
		}
		self.zone_infection = factory.create("#zone_infection_factory", go.get_position(), scale, properties)
	end
end

function M.on_update(self)
	if self.zone_infection then
		go.set_position(go.get_position(), self.zone_infection)
	end
end


function M.animate_position(self, position_to, duration)
	if self.zone_infection then
		go.animate(self.zone_infection, "position", go.PLAYBACK_ONCE_FORWARD, position_to, go.EASING_LINEAR, duration)
	end
end

function M.update_size(self, diametr)
	if self.zone_infection then
		go.set_scale(diametr, self.zone_infection)
	end
end

return M