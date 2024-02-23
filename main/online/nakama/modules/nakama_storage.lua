local defold = require "nakama.engine.defold"
local storage_player = require "main.storage.storage_player"

-- Хранилище для работы с накамой
local M = {
	--[[
	config = {
		host = "127.0.0.1",
		port = 7350,
		use_ssl = false,
		username = "defaultkey",
		password = "",
		engine = defold,
		timeout = 10, -- connection timeout in seconds
	},
	--]]
	config = {
		host = "nakama.heyalyosha.ru",
		port = 7350,
		use_ssl = true,
		username = "qe87LyiRzE3NCBIYlscNJsfqM0tm1C9Q",
		password = "",
		engine = defold,
		timeout = 10, -- connection timeout in seconds
	},
	OpCodes = {
		update_position = 1,
		update_input = 2,
		update_state = 3,
		update_activate = 4,
		do_spawn = 5,
		update_color = 6,
		initial_state = 7
	}
}

return M