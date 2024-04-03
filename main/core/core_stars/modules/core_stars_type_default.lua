-- Обработка звёзд миссии для стандартной логики звёзд достижения определённого кол-ва значения
local M = {}

local storage_game = require "main.game.storage.storage_game"
local gui_text = require "main.gui.modules.gui_text"

local lang_core = require "main.lang.lang_core"

-- Стартуем
function M.start(self, type, values_stars)
	storage_game.stars = {
		value = 0,
		type = type,
		values_stars = values_stars
	}
	storage_game.game.result.stars = 0
	local quest = game_content_stars.types[type].quest

	local stars = 0
	local list = {}

	for i, value in ipairs(values_stars) do
		list[i] = lang_core.get_text(self, quest, before_str, after_str, {value = value})
	end

	msg.post("/loader_gui", "set_content", {
		id = "interface",
		type = "stars",
		values = {
			stars = stars,
			list = list
		}
	})

	msg.post("/loader_gui", "set_status", {
		id = "interface",
		type = "stars_visible",
		visible = true
	})
end

-- Обновление
function M.update(self, value, operation)
	local operation = operation or "set"
	storage_game.stars = storage_game.stars or {}

	if operation == "set" then
		storage_game.stars.value = value
	elseif operation == "add" then
		storage_game.stars.value = storage_game.stars.value + value
	end

	local star = 0

	-- Находим какие 
	for i, value_to_star in ipairs(storage_game.stars.values_stars) do
		if storage_game.stars.value >= value_to_star then
			star = i
		end
	end

	-- Если кол-во звёзд изменилось
	if star ~= storage_game.game.result.stars then
		storage_game.game.result.stars = star 

		msg.post("/loader_gui", "set_content", {
			id = "interface",
			type = "set_star",
			values = {
				stars = star,
				unwrap = true
			}
		})
	end
end

return M