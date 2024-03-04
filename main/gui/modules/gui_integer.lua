-- работа с текстом в гуи
local M = {}

local richtext = require "richtext.richtext"
local color = require "richtext.color"

-- Разбить число на части
function M.to_parts(self, number, step, func)
	repeat
		local value

		if number >= step then
			value = step
		else
			value = number
		end
		number = number - value

		if value > 0 then
			if func then 
				func(self, value)
			end
		end
	until number <= 0
end

return M