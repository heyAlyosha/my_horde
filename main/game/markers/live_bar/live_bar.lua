-- Функции для показа шкалы здоровья
local M = {}

function M.create(self, is_player)
	if not self.hp_bar then
		if is_player then
			self.hp_bar = collectionfactory.create("#live_bar_collectionfactory", go.get_position())

			local url = msg.url(self.hp_bar[hash("/count")])
			local url_label = msg.url(url.socket, url.path, "count_horde")
			if self.horde_count_current < 1 then
				msg.post(url_label, "disable")
			else
				msg.post(url_label, "enable")
			end
		else
			self.hp_bar = collectionfactory.create("markers_core#live_bar_collectionfactory", go.get_position())
		end
		
	end
end

function M.update_position(self)
	if self.hp_bar then
		go.cancel_animations(self.hp_bar[hash("/live_bar")], "position")
		go.set_position(go.get_position(), self.hp_bar[hash("/live_bar")])
	end
end

function M.position_to(self, position, duration)
	if self.hp_bar then
		go.cancel_animations(self.hp_bar[hash("/live_bar")], "position")
		go.animate(self.hp_bar[hash("/live_bar")], "position", go.PLAYBACK_ONCE_FORWARD, position, go.EASING_LINEAR, duration)
	end
end

function M.set_hp(self, live, max_live)
	if self.hp_bar then
		local url_bg = msg.url(self.hp_bar[hash("/live_bar")])
		local url_hp = msg.url(self.hp_bar[hash("/hp")])

		local sx = go.get(msg.url(url_bg.socket, url_bg.path, "bg"), "size.x") - 2
		local procent = live / max_live
		local size_line = sx * procent

		-- Устанавливаем ширину
		go.set(msg.url(url_hp.socket, url_hp.path, "sprite"), "size.x", size_line)
		-- Устанавливаем позицию линии здоровья
		local position = go.get_position(url_hp)
		position.x = -(sx - size_line) / 2
		go.set_position(position, url_hp)
	end
end

function M.delete(self)
	if self.hp_bar then
		for k, id in pairs(self.hp_bar) do
			go.delete(id)
			self.hp_bar[k] = nil
		end
		self.hp_bar = nil
	end
end


return M