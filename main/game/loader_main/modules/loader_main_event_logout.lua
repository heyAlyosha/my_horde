-- События входа в игру
local M = {}
local color = require("color-lib.color")
local loader_main_logout = require "main.game.loader_main.modules.loader_main_logout"

function M.on(self, message)
	if message.id == "start_logout" then
		loader_main_logout.start(self)

	elseif message.error then
		loader_main_logout.error(self, message)

	elseif message.success then
		loader_main_logout.success(self, message)
		
	end
end

return M