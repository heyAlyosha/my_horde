-- Наборы для отправки в уведомления
local M = {}

local game_content_achieve = require "main.game.content.game_content_achieve"
local lang_core = require "main.lang.lang_core"

-- новое поступление в магазин
function M.update_shop(self, types_add_objects)
	local after_str = " "
	local count_types = 0 
	for type_name, v in pairs(types_add_objects) do
		count_types = count_types + 1
	end
	local index = 0
	for type_name, v in pairs(types_add_objects) do
		index = index + 1
		local type_title = lang_core.get_text(self, "_add_shop_type_"..type_name)
		if index < count_types then
			after_str = after_str .. type_title .. ", "
		else
			after_str = after_str .. type_title .. "."
		end
	end
	local data = {
		title_formated = lang_core.get_text(self, "_new_products_shop_title"),
		description = lang_core.get_text(self, "_new_products_shop_description", before_str, after_str),
		icon = "shop",
		btn = {
			title = utf8.upper(lang_core.get_text(self, "_to_shop_btn")),
			type = "shop"
		},
		sound = "open_shop"
	}

	msg.post("main:/loader_gui", "add_notify", {
		type = "button",
		data = data
	})
end

function M.add_achieve(self, id)
	local achieve = game_content_achieve.get_item(id)
	local title_modal = lang_core.get_text(self, "_new_achieve")
	local title_achieve = lang_core.get_text(self, achieve.title_id_string)
	local description_achieve = lang_core.get_text(self, achieve.description_id_string)

	local data = {
		--title_formated = title_modal.." - <color=lime>"..title_achieve.."</color>",
		title_formated = "<color=lime>"..title_achieve.."</color>",
		description = title_modal .. "! " .. description_achieve,
		icon = achieve.icon,
		progress_bar = {
			max =  achieve.max_count,
			progress_current = achieve.max_count,
			progress_animate = false
		},
		sound = "level_up"
	}

	msg.post("main:/loader_gui", "add_notify", {
		type = "progress",
		data = data
	})
end

return M