-- Функции для обучения
local M = {}

local lang_core = require "main.lang.lang_core"
local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"
local data_handler = require "main.data.data_handler"

local types = {
	study_type_hello = require "main.game.study.modules.types.study_type_hello",
	study_type_aim = require "main.game.study.modules.types.study_type_aim",
	study_type_sector_trap = require "main.game.study.modules.types.study_type_sector_trap",
	study_type_sector_catch = require "main.game.study.modules.types.study_type_sector_catch",
	study_type_catch = require "main.game.study.modules.types.study_type_catch",
	study_type_accuracy = require "main.game.study.modules.types.study_type_accuracy",
	study_type_speed_caret = require "main.game.study.modules.types.study_type_speed_caret",
	study_type_bank = require "main.game.study.modules.types.study_type_bank",
	study_type_artifact_catch = require "main.game.study.modules.types.study_type_artifact_catch",
	study_type_artifact_trap = require "main.game.study.modules.types.study_type_artifact_trap",
	study_type_obereg = require "main.game.study.modules.types.study_type_obereg",
	study_type_level_up = require "main.game.study.modules.types.study_type_level_up",
	study_type_shop_prizes = require "main.game.study.modules.types.study_type_shop_prizes",
	study_type_inventary = require "main.game.study.modules.types.study_type_inventary",
	study_type_shop = require "main.game.study.modules.types.study_type_shop",
	study_type_shop_no_product = require "main.game.study.modules.types.study_type_shop_no_product",
	study_type_shop_no_gold = require "main.game.study.modules.types.study_type_shop_no_gold",
	study_type_keyboard = require "main.game.study.modules.types.study_type_keyboard",
	study_type_stars = require "main.game.study.modules.types.study_type_stars",
	study_type_company = require "main.game.study.modules.types.study_type_company",
	study_type_continue_level = require "main.game.study.modules.types.study_type_continue_level",
	study_type_shop_for_game = require "main.game.study.modules.types.study_type_shop_for_game",
	study_type_reward_visit = require "main.game.study.modules.types.study_type_reward_visit",
}

-- Добавление части обучения
function M.add_item(self, id, is_not_set, no_hello)
	if M.is_show_help(self, id) then
		-- Если не было знакомства с обучением
		if not no_hello and not storage_player.study.hello then
			table.insert(self.items_study, "hello")
		end

		table.insert(self.items_study, id)
	end

	if #self.items_study > 0  and not self.current_study_id then
		msg.post("/loader_gui", "visible", {
			id = "character_dialog",
			visible = false,
		})
		msg.post("main:/loader_gui", "visible", {
			id = "study",
			visible = false
		})
		timer.delay(0.1, false, function (self)
			M.play_first_item(self, is_not_set)
		end)
	end
end

-- Добавление части обучения
function M.clear_prev_items(self)
	for i = #self.items_study, 1, -1 do
		local item = self.items_study[i]

		if item ~= "hello" then
			table.remove(self.items_study, i)
		end 
	end
end

-- Запуск части обучения
function M.play_first_item(self, is_not_set)
	if #self.items_study > 0  and not self.current_study_id then
		self.current_study_id = self.items_study[1]

		if not is_not_set then
			storage_player.study[self.current_study_id] = true
		end

		table.remove(self.items_study, 1)

		-- Сохраняем, что посмотрели
		local userdata = {
			study = storage_player.study
		}
		data_handler.set_userdata(self, userdata, callback)

		if types["study_type_"..self.current_study_id] then
			types["study_type_"..self.current_study_id].start(self)
		end
	end
end

-- Нужно ли показывать обучение
function M.is_show_help(self, id)
	local settings = api_player.get_settings(self)
	return settings.study and not storage_player.study[id]
end

-- Сообщения разных типов обучения
function M.on_message_type(self, message_id, message, sender)
	if self.current_study_id and types["study_type_"..self.current_study_id] then
		types["study_type_"..self.current_study_id].on_message(self, message_id, message, sender)
	end
end

return M