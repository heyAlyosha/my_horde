local M = {}

local api_player = require "main.game.api.api_player"
local gui_loyouts = require "main.gui.modules.gui_loyouts"

-- Показ рекламы
function M.show_ads(self, type_ads)
	msg.post(".", "acquire_input_focus")
	--print("ADS SHOW", type_ads)

	self.visible = true
	self.type_ads = type_ads

	gui_loyouts.set_enabled(self, self.nodes.wrap, self.visible)

	local settings = api_player.get_settings(self)
	self.volume = {
		volume_music = settings.volume_music,
		volume_effects = settings.volume_effects
	}

	-- Отклюбчаем музыку и звуки
	msg.post("main:/music", "volume", {volume = 0})
	msg.post("main:/sound", "volume", {volume = 0})

	self.btn_active = true
	gui_loyouts.set_enabled(self, self.nodes.btn_close, false)

	local timer_visible_close_btn 
	if type_ads == "reward" then
		timer_visible_close_btn = 5
	else
		timer_visible_close_btn = 3
	end
	if self.timer_close_btn then
		timer.cancel(self.timer_close_btn)
		self.timer_close_btn = nil
	end
	self.timer_close_btn = timer.delay(timer_visible_close_btn, false, function (self)
		self.btn_active = true
		gui_loyouts.set_enabled(self, self.nodes.btn_close, self.btn_active)
	end)
end

-- Скрытие
function M.hidden_ads(self, type_ads, status)
	print("ADS HIDDEN", type_ads, status)
	self.visible = false
	self.type_ads = type_ads or self.type_ads
	gui_loyouts.set_enabled(self, self.nodes.wrap, self.visible)

	-- Включаем музыку и звуки
	msg.post("main:/music", "volume", {volume = self.volume.volume_music})
	msg.post("main:/sound", "volume", {volume = self.volume.volume_effects})

	msg.post(self.sender, "ads_close", {type_ads = self.type_ads, status = status})

end

return M