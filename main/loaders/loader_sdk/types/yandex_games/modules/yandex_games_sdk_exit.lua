-- Выход из игры
local yagames = require("yagames.yagames")

local M = function ()
	yagames.event_dispatch("EXIT")
end

return M