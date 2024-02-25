-- Функции для работы с гуи 
local M = {}

local color = require("color-lib.color")
local storage_gui = require "main.storage.storage_gui"
local core_live_update = require "main.game.live_update.core_live_update"
local lang_core = require "main.lang.lang_core"

-- Создание компонента
function M.create_component(self, id, message, sender, message_id)
	-- Обычный компонент гуи
	storage_gui.components_visible_hash_to_id[hash(message.id)] = message.id
	storage_gui.components_visible_sender_to_id[sender] = message.id
	local url = msg.url(factory.create("#"..message.id .. "_factory", nil, nil, message.properties))
	storage_gui.components_visible[message.id] = url

	msg.post("game-room:/core_game", "event", {id = "visible_gui", component_id = message.id, value = message.value or message.values })
	msg.post("main:/core_study", "event", {id = "visible_gui", component_id = message.id, value = message.value or message.values })
	
	if message_id == hash("visible") then
		msg.post(storage_gui.components_visible[message.id], message_id, message)
	end

end

-- Создание компонента
function M.delete_component(self, id, all_msg)
	go.delete(storage_gui.components_visible[id], true)

	storage_gui.components_visible[id] = nil
	storage_gui.components_status[id] = {}
	storage_gui.components_content[id] = {}

	if all_msg then
		for k, url in pairs(storage_gui.components_visible) do
			msg.post(url, "event", {id = "close_gui", component_id = id})
		end
	end
	msg.post("game-room:/core_game", "event", {id = "close_gui", component_id = id})
	msg.post("main:/core_study", "event", {id = "close_gui", component_id = id})
end

-- Создание компонента фона
function M.create_bg(self, parent_id, message_id, message, sender)
	storage_gui.components_bg[parent_id] = factory.create("#bg_factory", nil, nil, message.properties)
	msg.post(storage_gui.components_bg[parent_id], message_id, message)

end

-- Удаление компонента фона
function M.delete_bg(self, parent_id, message_id, message, sender)
	-- Удаляем
	go.delete(storage_gui.components_bg[parent_id], true)
	storage_gui.components_bg[parent_id] = nil

end

-- Удаляем компоненты из коллекции
function M.clear_collections_visible(self, socket)
	for id, url in pairs(storage_gui.components_visible) do
		
		if url.socket == hash(socket) then
			storage_gui.components_visible[id] = nil 
		end
	end

	

end



return M