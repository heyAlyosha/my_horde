local M = {}

local storage_gui = require "main.storage.storage_gui"
local storage_sdk = require "main.storage.storage_sdk"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"

function M.render(self)
	gui_lang.set_text_upper(self, self.nodes.btn_play_title, "_start_play")
	gui_lang.set_text_upper(self, self.nodes.btn_trophy_title, "_my_prizes")
	gui_lang.set_text_upper(self, self.nodes.btn_rating_title, "_best_players")
	gui_lang.set_text_upper(self, self.nodes.btn_exit_title, "_exit")

	self.btns = {
		{id = "play", type = "btn", section = "main_1", node = self.nodes.btn_play_wrap,  node_title = self.nodes.btn_play_title, icon = "main_menu_btn_"},
		{id = "play_family", type = "btn", section = "main_2", node = self.nodes.btn_play_family_wrap,  node_title = self.nodes.btn_play_family_title, icon = "main_menu_btn_"},
		{id = "trophy", type = "btn", section = "main_3", node = self.nodes.btn_trophy_wrap,  node_title = self.nodes.btn_trophy_title, icon = "main_menu_btn_"},
		{id = "rating", type = "btn", section = "main_4", node = self.nodes.btn_rating_wrap,  node_title = self.nodes.btn_rating_title, icon = "main_menu_btn_"},
		{id = "exit", type = "btn", section = "main_5", node = self.nodes.btn_exit_wrap,  node_title = self.nodes.btn_exit_title, icon = "main_menu_btn_"},
		{id = "login", type = "btn", section = "main_6", node = self.nodes.btn_login_wrap,  node_title = self.nodes.btn_login_title, icon = "button_default_blue_"},
	}

	-- Если игрок не авторизован
	gui_loyouts.set_enabled(self, self.nodes.login_wrap, storage_sdk.player.is_anonime)
	if not storage_sdk.player.is_anonime then
		for i, btn in ipairs(self.btns) do
			if btn.id == "login" then
				table.remove(self.btns, i)
			end
		end
	end

	-- Если вигре нет выхода
	pprint("storage_sdk.stats.is_exit", storage_sdk.stats.is_exit)
	gui_loyouts.set_enabled(self, self.nodes.btn_exit_wrap, storage_sdk.stats.is_exit)
	if not storage_sdk.stats.is_exit then
		for i, btn in ipairs(self.btns) do
			if btn.id == "exit" then
				table.remove(self.btns, i)
			end
		end
	end
end

return M 