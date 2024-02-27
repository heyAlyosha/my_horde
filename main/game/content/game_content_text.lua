-- Храним контент для текста
local storage_player = require "main.storage.storage_player"

local M = {}

M.content = {
	complexity = {
		easy = {ru = "Лёгкий"},
		normal = {ru = "Средний"},
		hard = {ru = "Тяжёлый"},
	},
	type_fail = {
		fail_word = {ru = ""},
		win_other_gamer = {ru = ""},
		surrender = {ru = ""},
	},
	fail_title = {ru = "ТЫ ПРОИГРАЛ"},
	fail_description = {ru = "Попробуешь заново?"},
	fail_tournir_description = {ru = "Сразишься с другими противниками?"},
	win_title =  {ru = "ТЫ ПОБЕДИЛ"},
	prize_title =  {ru = "ТВОИ ПРИЗЫ"},
	rating = {
		top_title = {ru = "РЕЙТИНГ ЛУЧШИХ ИГРОКОВ"},
		personal_title = {ru = "МОЁ МЕСТО В РЕЙТИНГЕ"},
		yandex_title = {ru = "РЕЙТИНГ ИГРОКОВ ИЗ ЯНДЕКС ИГР"},
		title_change_animated = {ru = "ТВОЁ МЕСТО В РЕЙТИНГЕ"}
	},
	name = {success_set_name = {ru = "УСПЕШНО ИЗМЕНЕНО"}},
	errors = {
		name_censoored = {ru = "МАТ ЗАПРЕЩЁН"},
		name_length = {ru = "ДЛИНА ИМЕНИ ДОЛЖНА БЫТЬ НЕ БОЛЬШЕ 30 СИМВОЛОВ"},
		name_error = {ru = "ПРОИЗОШЛА ОШИБКА ПРИ СОХРАНЕНИИ ИМЕНИ"},
		name_nil = {ru = "ИМЯ НЕ ДОЛЖНО БЫТЬ ПУСТЫМ"},
	},
	-- Характеристики
	mind = {
		title = {ru = "Интеллект"},
		description = {ru = "С каждым уровнем на 10 очков опыта больше за открытую букву и продажу приза."},
	},
	accuracy = {
		title = {ru = "Меткость"},
		description = {ru = "Точность вращения барабана выше на 5 за уровень."},
	},
	charisma = {
		title = {ru = "Харизма"},
		description = {ru = "С каждым уровнем у торговцев больше подарков для покупки."},
	},
	trade = {
		title = {ru = "Торговля"},
		description = {ru = "Цена продажи призов выше на 10% от стоимости покупки за очки в игре."},
	},
	speed_caret = {
		title = {ru = "Реакция"},
		description = {ru = "Скорость каретки силы вращения барабана меньше на 20 за каждый уровень."},
	},
	characteristics = {
		description = {ru = "ОЧКОВ УЛУЧШЕНИЙ: <color=yellow>{{points}}</color>"},
		current_val = {ru ="У ТЕБЯ: {{value}}"},
		next_val = {ru = "УЛУЧШИТЬ ДО:  <color=lime>{{value}}</color>"},
		skip_up_level = {ru = "ПРОПУСТИТЬ"},
		skip_default = {ru = "ПРОДОЛЖИТЬ"},
	},
	obereg = {
		reward = {ru = "ПОЛУЧИ ОБЕРЕГ ЗА ПРОСМОТР РЕКЛАМЫ."},
		skipping =  {ru = "ИСПОЛЬЗУЙ ОБЕРЕГ, ЧТОБЫ <color=lime>НЕ ПРОПУСТИТЬ ХОД</color>."},
		bankrupt = {ru = "ИСПОЛЬЗУЙ ОБЕРЕГ, ЧТОБЫ НЕ ПОТЕРЯТЬ <color=yellow>{{score}} ОЧКОВ</color>."},
		trap_skip = {ru = "ИСПОЛЬЗУЙ ОБЕРЕГ, ЧТОБЫ ЗАЩИТИТЬСЯ ОТ КАПКАНА, <color=lime>НЕ ПРОПУСТИТЬ ХОД</color> И СОХРАНИТЬ <color=yellow>{{score}} ОЧКОВ</color>."},
		trap_default = {ru = "ИСПОЛЬЗУЙ ОБЕРЕГ, ЧТОБЫ ЗАЩИТИТЬС ОТ КАПКАНА И СОХРАНИТЬ <color=yellow>{{score}} ОЧКОВ</color> ."},
	}
}

-- Получение текста в зависимости от языка
function M.get_local_text(category_id, id, lang)
	local lang = lang or storage_player.lang_tag
	if not category_id and M.content[id] and M.content[id][lang] then
		return M.content[id][lang]
	elseif M.content[category_id] and M.content[category_id][id] and M.content[category_id][id][lang] then
		return M.content[category_id][id][lang]
	else
		return "-"
	end
end

return M