-- Выход из игры
local M = function ()
	html5.run([=[
	window.assistant_client.sendData(
	{
		action: {
			action_id: 'EXIT'
		}
	});]=])
end

return M