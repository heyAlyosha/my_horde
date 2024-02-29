-- ИИ зомби
local M = {}

-- Спокойная жизнь бота
function M.live(self)
	self.view = ai_core.view(self, function (self, visible_items)
		if visible_items then
			-- Убегает от врагов
			self.animation_walking = nil
			if not self.animation_run then
				sprite.play_flipbook("#body", "human_"..self.human_id .. "_running")
				ai_move.move_item_from(self, go.get_position(visible_items[1].url), function (self)
					sprite.play_flipbook("#body", "human_"..self.human_id .. "_default")
					self.animation_run = nil
				end, self.speed_from)
			end
			--return true
		else
			-- Гуляет
			if not self.to_point then
				-- Нет точек следования
				if not self.animation_walking then
					self.animation_walking = true
					if math.random(1, 4) <= 3 then
						-- рандомное направление
						math.randomseed()
						local random_p
						if not self.random_dir then
							self.random_dir = vmath.vector3(1, 0, 0)
							random_p = math.random(1, 314) / 100
						else
							self.random_dir = self.random_dir
							random_p = math.random(1, 628) / 100
						end
						local rot = vmath.quat_rotation_z(random_p)
						random_position  = vmath.rotate(rot, self.random_dir) * 50 + go.get_position() 

						sprite.play_flipbook("#body", "human_"..self.human_id .. "_walking")
						ai_move.move_item_from(self, random_position, function (self)
							self.animation_walking = nil
							sprite.play_flipbook("#body", "human_"..self.human_id .. "_default")
							M.live(self)
						end, self.speed)
					else
						-- Просто стоит
						timer.delay(2, false, function (self)
							self.hflip = not self.hflip
							sprite.set_hflip("#body", self.hflip)
							sprite.play_flipbook("#body", "human_"..self.human_id .. "_default")
							self.animation_walking = nil
						end)
					end
				end
			else
			end
		end
	end)
end

return M