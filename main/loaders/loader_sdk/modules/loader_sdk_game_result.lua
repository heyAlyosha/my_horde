-- Логика сдк после окончания игры игрококм
local M = {}

local storage_sdk = require "main.storage.storage_sdk"
local storage_player = require "main.storage.storage_player"
local loader_sdk_modules = require "main.loaders.loader_sdk.modules.loader_sdk_modules"

-- Когда игрок победил
function M.user_win(self)
	-- Если есть возможность рейтинга и игрок его не ставил - предлагаем ему
	if  
	storage_sdk.stats.is_rating and
	(not storage_player.feedback or not storage_player.feedback.star or not storage_player.feedback.star[sys.get_config("platform.platform")]) 
	then
		msg.post("main:/loader_gui", "visible", {id = "modal_stars", visible = true})
	end
end

-- Когда игрок проиграл
function M.user_fail(self)
	local is_rating = storage_sdk.stats.is_rating and (not storage_player.feedback or not storage_player.feedback.star or not storage_player.feedback.star[sys.get_config("platform.platform")]) 

	if is_rating and storage_player.user_metadata.count_play_game and storage_player.user_metadata.count_round_play_game and (storage_player.user_metadata.count_play_game > 1 or storage_player.user_metadata.count_round_play_game > 3) then
		-- Если есть возможность поставить оценку игры и игрок зашёл повторно или сыграл больше 3-х раундом
		msg.post("main:/loader_gui", "visible", {id = "modal_stars", visible = true})
	else
		-- Во всех остальных случаях показываем полноэкранную рекламу
		loader_sdk_modules.ads.ads_fullscreen_visible(self, true)
	end
end

return M