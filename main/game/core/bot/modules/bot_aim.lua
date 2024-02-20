-- Функции для прицеливания 
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_content_wheel = require "main.game.content.game_content_wheel"

function M.on_update(self, dt)
	-- Если включён aim начинаем
	self.time_aim = self.time_aim or 0
	self.dif = self.dif or dt

	if self.time_aim >= self.speed_aim then
		self.dif = -dt
	elseif self.time_aim <= 0 then
		self.dif =  dt
	end

	if not self.full_rotate_aim then
		self.full_rotate_aim = self.time_aim >= self.speed_aim
	end

	self.time_aim = self.time_aim + self.dif

	self.procent = self.time_aim / self.speed_aim

	msg.post("game-room:/loader_gui", "set_content", {
		id = "game_wheel",
		type = "aim",
		value = {
			procent = 1 - self.procent
		}
	})

	if self.full_rotate_aim and M.is_aim_sector(self, self.aim_sector_id) and not self.rotate_wheel_timer then
		local random_delay = math.random(10, 25)/100
		if self.timer_default_rotate then
			timer.cancel(self.timer_default_rotate)
			self.timer_default_rotate = nil
		end
		self.rotate_wheel_timer = timer.delay(random_delay, false, function (self)
			-- Вращаем барабан
			msg.post("game-room:/loader_gui", "set_content", {
				id = "game_wheel",
				type = "rotate",
				value = {
					procent = self.procent
				}
			})
		end)
	end
end

function M.on_message(self, message_id, message)
	-- Прицеливание
	local bot_id = message.bot_id
	local player_id = message.player_id
	local bot = game_core_gamers.get_player(self, player_id, game_content_wheel)

	msg.post("game-room:/loader_gui", "set_status", {
		id = "game_wheel",
		type = "visible_aim",
		visible = true,
		value = {
			player_id = player_id, 
		}
	})

	-- Получаем скорость, делим на 2 , тк. это время за туда и обратно
	self.speed_aim = game_content_wheel.get_speed_aim(self, player_id) / 2 

	-- Получаем сектор для прицеливания
	self.aim_sectors = M.sort_sectors(self, bot)

	if self.aim_sectors[1] then
		-- Выбираем случайный сектор из 2х выгодных
		local random_sector = self.aim_sectors[math.random(1,2)]
		if random_sector then
			self.aim_sector_id = random_sector.id

		else
			self.aim_sector_id = self.aim_sectors[1].id
		end
		
	else
	
	end

	-- Дефолтный запасной таймер
	self.timer_default_rotate = timer.delay(math.random(300, 500)/100, false, function (self)
		msg.post("game-room:/loader_gui", "set_content", {
			id = "game_wheel",
			type = "rotate",
			value = {
				procent = self.procent
			}
		})
	end)

	self.aim = true
end

-- Сортируем возможные скетора
function M.sort_sectors(self, bot)
	local result = {}

	for i, item in ipairs(storage_game.possible_aim_sectors) do
		local new_item = {}

		-- Находим ценность
		new_item.treasure = item.value.score or 0

		if item.type == "skip" then
			new_item.treasure = new_item.treasure - 2000

		elseif item.type == "open_symbol" then
			new_item.treasure = 100

		elseif item.type == "bankrot" then
			new_item.treasure = -bot.score 

		elseif item.type == "x2" then
			new_item.treasure = bot.score * 2

		else
			new_item.score_sector = item.value.score
		end

		new_item.type = item.type

		-- Захвачен ли сектор
		local treasure_artifact = 0
		if item.player and item.player.player_id ~= bot.player_id then
			new_item.player = item.player.player_id

			if item.artifact then
				new_item.artifact_type = item.artifact.type
				new_item.artifact_id = item.artifact.id
			end
			if not item.artifact  then
				-- Просто захваченный сектор
				treasure_artifact = -10

			elseif item.artifact and item.artifact.type == "catch" then
				--Сувенир
				treasure_artifact = -item.artifact.value.score

			elseif item.artifact and item.artifact.type == "trap" then
				-- Капкан
				treasure_artifact = -item.artifact.value.score

			end


			-- Если сектор захвачен, то понижаем его ценность перед другими
			treasure_artifact = treasure_artifact - 200

		end

		new_item.treasure = new_item.treasure + treasure_artifact
		new_item.id = item.id

		result[#result + 1] = new_item
	end

	-- Сортируем по ценности
	table.sort(result, function (a, b) return (a.treasure > b.treasure) end)

	return result

end

-- Попадает ли сектор в прицел
function M.is_aim_sector(self, sector_id)
	for i = 1, #storage_game.possible_aim_sectors do
		local sector = storage_game.possible_aim_sectors[i]

		if sector_id == sector.id then
			return true
		end
	end

	return false
end

return M