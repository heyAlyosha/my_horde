-- Объединенные модули для управления SDK
local M = {}

-- Модуль выставления оценок игре
M.stars = {
	-- Пользователь поставил плохую оценку
	bad_star = function (self) end,
	-- Пользователь поставил хорошую оценку
	good_star = function (self) end,
	-- Пользователь активирует кнопку "Оценить в каталоге"
	activate_catalog_rating = function (self) end,
	-- Пришла оценка от плафтормы
	sdk_set_star = function (self, data) end,
}

-- Модуль покупок и активации разных методов получения монет
M.shop = {
	-- Пользователь поставил плохую оценку
	get_products = function (self) end,
	-- Пользователь активирует какой-то способ пополнения монет
	activate_item_shop = function (self, id) end,
}

-- Модуль управления рекламой
M.ads = {
	-- Изменение видимости горизонтального блока рекламы
	ads_bottom_horisontal_visible = function (self, visible)
		msg.post("main:/loader_gui", "visible", {id = "ads_bottom_horisontal", visible = visible})
		msg.post("main:/loader_gui", "visible", {id = "banner_horisontal_default", visible = visible})
	end,

	-- Bзменеине видиммости полнорэкранной рекламы
	ads_fullscreen_visible = function (self, visible)
		msg.post("main:/loader_gui", "visible", {id = "modal_fullscreen_ads", visible = visible})
	end,

	-- Изменение видимости рекламы за вознаграждение
	ads_rewarded_visible = function (self, visible) 
		
	end,
}

-- Модуль авторизации на сервере 
M.logout = {
	-- Начинаем авторизацию
	start = function () end,
}

-- Выход из игры (если есть)
M.exit = function ()
	msg.post("@system:", "exit", {code = 0})
end

return M