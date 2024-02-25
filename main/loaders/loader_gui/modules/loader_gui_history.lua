-- История сообщений в компоненты
local M = {}

local storage_gui = require "main.storage.storage_gui"

-- Лоавим сообщения
function M.on_message(self, message_id, message, sender)
	if message_id == hash("visible") and not message.visible then
		-- Если скрывают компоненент, то удаляем его историю
		local id = message.id
		storage_gui.components_history_msg[id] = nil
	else
		-- Все остальные записываем
		local id = message.id
		if not message.refresh_history and id then 
			storage_gui.components_history_msg[id] = storage_gui.components_history_msg[id] or {}
			table.insert(storage_gui.components_history_msg[id], {
				message_id = message_id, message = message, sender = sender
			})
		end
	end
end

-- повторить все сообщения
function M.refresh_msg(self, id, type_refresh, not_reload)
	if not storage_gui.components_history_msg[id] then
		return false
	end

	local msgs = {}
	local history_items = storage_gui.components_history_msg[id]
	

	if type_refresh == "last" then
		-- Добавляем только самое последнее сообщение
		msgs[1] = history_items[#history_items]
	else
		for i, item in ipairs(history_items) do
			msgs[i] = item
		end
	end

	-- Рассылаем
	msg.post("/loader_gui", "visible", {id = id, visible = false})
	for i, item in ipairs(msgs) do
		local message_id = item.message_id
		local message = item.message
		--message.refresh_history = true
		msg.post("/loader_gui", message_id, message)
	end 
end

return M