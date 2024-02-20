-- Функции для открытия букв
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_content_wheel = require "main.game.content.game_content_wheel"
local game_content_bots = require "main.game.content.game_content_bots"

M.ai = {
	easy = 15,
	normal = 25,
	hard = 40,
}

function M.activate(self, bot_id, sector_id)
	local bot = game_content_bots.get(bot_id)
	local bot_ai = bot.complexity
	local close_symbols = {}
	local keyboards_symbols = storage_game.bot.keyboard
	local success_response = self.success_response or 0
	local chance_success = M.ai[bot_ai] - success_response * 10
	local response_success = false
	local symbol = storage_game.bot.keyboard[math.random(#storage_game.bot.keyboard)]
	local min_chance = 5

	if chance_success < min_chance then
		chance_success = min_chance
	end

	-- Смотрим какие закрыты буквы на табло
	for i, item in ipairs(storage_game.game.round.tablo) do
		if not item.open then
			table.insert(close_symbols, item.symbol)
		end
	end

	-- если это последняя буква, бот открывает её
	if #close_symbols <= 1 then
		msg.post("/loader_gui", "set_status", {
			id = "keyboard_ru",
			type = "activate_symbol",
			value = {
				symbol = close_symbols[1]
			}
		})

		return true

	elseif #close_symbols == 2 then
		-- Если осталось мало букв, увеличиваем шансы на правильный ответ
		chance_success = chance_success + 30

	elseif #close_symbols == 3 then
		-- Если осталось мало букв, увеличиваем шансы на правильный ответ
		chance_success = chance_success + 10
	end

	-- Если обучение снижаем шанс правильного ответа
	if storage_game.game.study_level and storage_game.game.study_level > 0 then
		chance_success = 1
	end

	print("chance_success", chance_success, "#close_symbols:", #close_symbols)

	-- если это последняя заблокированная буква, бот открывает её
	if #keyboards_symbols <= 1 then
		msg.post("/loader_gui", "set_status", {
			id = "keyboard_ru",
			type = "activate_symbol",
			value = {
				symbol = keyboards_symbols[1].symbol
			}
		})
		return true
	end

	math.randomseed(os.clock())

	response_success = math.random(100) <= chance_success

	if response_success then
		-- Бот должен правильно ответить
		local random_item = close_symbols[math.random(#close_symbols)]
		symbol = random_item
	else
		-- Бот должен ошибиться
		local random_item = keyboards_symbols[math.random(#keyboards_symbols)]
		symbol = random_item.symbol
	end

	msg.post("/loader_gui", "set_status", {
		id = "keyboard_ru",
		type = "activate_symbol",
		value = {
			symbol = symbol
		}
	})

end

function M.sector_open_symbol(self, bot)
	
	local close_symbols = {}
	-- Смотрим какие закрыты буквы на табло
	for i, item in ipairs(storage_game.game.round.tablo) do
		if not item.open then
			table.insert(close_symbols, item.symbol)
		end
	end

	local random_item = close_symbols[math.random(#close_symbols)]
	symbol = random_item

	--msg.post("/game-room/scene_tablo", "open_symbol", {symbol = symbol})
	msg.post("game-room:/core_game", "event", {
		id = "open_symbol",value = {symbol = symbol,}
	})
end

return M