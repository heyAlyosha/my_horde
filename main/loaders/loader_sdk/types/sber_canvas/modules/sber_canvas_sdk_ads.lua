-- Управление оценками в игре
local M = {}

--local screen_content = require "main.content.screen.screen_content"
local storage_sdk = require "main.storage.storage_sdk"
local storage_player = require "main.storage.storage_player"
local nakama = require "nakama.nakama"
local json = require "nakama.util.json"
local loader_sdk_rpc = require "main.loaders.loader_sdk.modules.loader_sdk_rpc"

-- Изменение видимости горизонтального блока рекламы
function M.ads_bottom_horisontal_visible(self, visible)
	if visible and storage_player.is_subscribe() then
		return
	end

	msg.post("main:/loader_gui", "visible", {id = "ads_bottom_horisontal", visible = visible})
	msg.post("main:/loader_gui", "visible", {id = "banner_horisontal_default", visible = visible})
end

-- Изменеине видиммости полнорэкранной рекламы
function M.ads_fullscreen_visible(self, visible)
	if visible and storage_player.is_subscribe() then
		html5.run([=[
		window.SberDevicesAdSDK.runBanner({
			onSuccess: () => {
				console.log('Banner success');
			},
			onError: (err) => {
				console.error('Banner Error', err);
			},
		});
		]=])
	end
end

-- Изменение видимости рекламы за вознаграждение
function M.ads_rewarded_visible(self, visible)
	if visible then
		local mute = (not storage_player.params.sound and not storage_player.params.sound_bg and not storage_player.params.music)
		mute = tostring(mute)

		html5.run([=[
		window.SberDevicesAdSDK.runVideoAd({
			onSuccess: () => {
				JsToDef.send("RewardShow", {
					type: "video_success"
				})
			},
			onError: (err) => {
				JsToDef.send("RewardShow", {
					type: "video_error"
				})
			},
			mute: ]=]..mute..[=[,
		});
		]=])
	end
end

return M