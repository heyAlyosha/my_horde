-- Переводы текста для ГУИ 
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local csv = require  "main.modules.csv"
local lang_core = require "main.lang.lang_core"
local gui_text = require "main.gui.modules.gui_text"

M.data = {}
M.lang = "ru"

-- Запись изменения в хранилище
local function set_storage(self, node, id_string, before_str, after_str)
	local id = gui.get_id(node)

	self._gui_langs = self._gui_langs or {}
	self._gui_langs[id] = self._gui_langs[id] or {}
	self._gui_langs[id] = {
		node = node, id_string = id_string, before_str = before_str, after_str = after_str
	}

	return id, type, self._gui_langs[id]
end

-- Сообщения
function M.on_message(self, message_id, message)
end

function M.set_text(self, node, id_string, before_str, after_str)
	local string = lang_core.get_text(self, id_string, before_str, after_str)

	gui_loyouts.set_text(self, node, string)
	return set_storage(self, node, id_string, before_str, after_str)
end

function M.set_text_upper(self, node, id_string, before_str, after_str)
	local string = lang_core.get_text(self, id_string, before_str, after_str)
	gui_loyouts.set_text(self, node, utf8.upper(string))
	return set_storage(self, node, id_string, before_str, after_str)
end

function M.set_text_formated(self, node, id_string, before_str, after_str)
	local string = lang_core.get_text(self, id_string, before_str, after_str)

	gui_text.set_text_formatted(self, node, string)
	return set_storage(self, node, id_string, before_str, after_str)
end

function M.druid_text(self, node, id_string) 
	local string = lang_core.get_text(self, id_string)
	self._lang_druid_storage = self._lang_druid_storage or {}
	self._lang_druid_storage.text = self._lang_druid_storage.text or {}

	if not self._lang_druid_storage.text[gui.get_id(node)] then
		self._lang_druid_storage.text[gui.get_id(node)] = self.druid:new_text(node, string)
	else
		self._lang_druid_storage.text[gui.get_id(node)]:set_to(string)
	end

	return set_storage(self, node, id_string)
end

return M