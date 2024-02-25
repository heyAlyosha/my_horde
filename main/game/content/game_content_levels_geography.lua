-- Храним контент для категорий вопроса
local M = {
	{
		id = 1,
		-- Вопросы
		quests = {
			{quest = "Как называют жителей Косово? ", word = "косовары"},
			{quest = "Так называеют крупное поместье в нектороых  странах мира.", word = "фазенда"},
			{quest = "Так называют углубление, по которому течёт поток воды.", word = "русло"},
		},
		-- Игроки
		party = {"player", "andrew", "igor"},
		complexity = "easy",
		stars = {
			type = "score", star_1 = 150, star_2 = 500, star_3 = 750,
		}
	},
	{
		id = 2,
		-- Вопросы
		quests = {
			{quest = "Страна, которую называют «земля обетованная».", word = "израиль"},
			{quest = "Этот прибор использует свойство магнитов.", word = "компас"},
			{quest = "Какая река дважды пересекает экватор?", word = "конго"},
		},
		-- Игроки
		party = {"player", "denis", "ira"},
		complexity = "easy",
		stars = {
			type = "score", star_1 = 250, star_2 = 500, star_3 = 1000,
		}
	},
	{
		id = 3,
		-- Вопросы
		quests = {
			{quest = "Святой, который покровительствует Ирландии.", word = "патрик"},
			{quest = "Одно из разновидностей путешествия.", word = "круиз"},
			{quest = "Где растёт знаменитое растение баобаб?", word = "саванна"},
		},
		-- Игроки
		party = {"player", "ira", "igor"},
		complexity = "easy",
		stars = {
			type = "score", star_1 = 250, star_2 = 500, star_3 = 1000,
		}
	},
	{
		id = 4,
		-- Вопросы
		quests = {
			{quest = "Страна пламени и льда.", word = "исландия"},
			{quest = "Страна из тысячи островов.", word = "индонезия"},
			{quest = "Так называю скопление мелких пригородов вокруг центрального города.", word = "агломерация"},
		},
		-- Игроки
		party = {"player", "igor", "denis"},
		complexity = "easy",
		stars = {
			type = "score", star_1 = 250, star_2 = 500, star_3 = 1000,
		}
	},
	{
		id = 5,
		-- Вопросы
		quests = {
			{quest = "Самая высокая вершина?", word = "джомолунгма"},
			{quest = "Зеленая автономная территория Дании.", word = "гренландия"},
			{quest = "Страна «зеленого золота» и «золотых плодов».", word = "бразилия"},
		},
		-- Игроки
		party = {"player", "denis", "lena"},
		complexity = "normal",
		stars = {
			type = "score", star_1 = 250, star_2 = 1000, star_3 = 1500,
		}
	},
	{
		id = 6,
		-- Вопросы
		quests = {
			{quest = "Этого путешественника называют русским Колумбом?", word = "беринг"},
			{quest = "Страна, где «тысячи озер».", word = "финляндия"},
			{quest = "Страна, считающаяся хлебной корзиной мира.", word = "турция"},
			{quest = "Это природное явление является излюбленной точкой для фотографов и туристов.", word = "водопад"},
		},
		-- Игроки
		party = {"player", "max", "ira"},
		complexity = "normal",
		stars = {
			type = "score", star_1 = 250, star_2 = 1000, star_3 = 1500,
		}
	},
	{
		id = 7,
		-- Вопросы
		quests = {
			{quest = "Кто открыл пролив между Америкой и Азией?", word = "дежнев"},
			{quest = "Страна, которую называют «большой деревней».", word = "канада"},
			{quest = "Столица какой страны расположена на реке Нил?", word = "египет"},
		},
		-- Игроки
		party = {"player", "lena", "antonina"},
		complexity = "normal",
		stars = {
			type = "score", star_1 = 250, star_2 = 1000, star_3 = 1500,
		}
	},
	{
		id = 8,
		-- Вопросы
		quests = {
			{quest = "Как называется столица Ливии?", word = "триполи"},
			{quest = "Какое государство названо по имени столицы иного государства?", word = "румыния"},
			{quest = "Какая страна, не имеет выхода к морю, но относится к бассейнам 4-х морей.", word = "швейцария"},
		},
		-- Игроки
		party = {"player", "alyona", "max"},
		complexity = "normal",
		stars = {
			type = "score", star_1 = 250, star_2 = 1000, star_3 = 1500,
		}
	},
	{
		id = 9,
		-- Вопросы
		quests = {
			{quest = "Самая северная столица Европы.", word = "рейкьявик"},
			{quest = "Озеро, лежащее в тектонической трещине на высоте 773 метров.", word = "танганьика"},
			{quest = "Озеро, в котором одна половина с пресной водой, а вторая – с соленой.", word = "титикака"},
		},
		-- Игроки
		party = {"player", "antonina", "lyosha"},
		complexity = "hard",
		stars = {
			type = "score", star_1 = 500, star_2 = 1500, star_3 = 2000,
		}
	},
	{
		id = 10,
		-- Вопросы
		quests = {
			{quest = "Какую столицу основал Одиссей после того, как уехал из Трои?", word = "лиссабон"},
			{quest = "Растение в Африке со стволом в 50 см и листьями по 3 метра.", word = "вельвичия"},
			{quest = "Молодые горы, граничащие с пустыней Сахарой.", word = "атлас"},
		},
		-- Игроки
		party = {"player", "max", "proskovia"},
		complexity = "hard",
		stars = {
			type = "score", star_1 = 500, star_2 = 1500, star_3 = 2000,
		}
	},
	{
		id = 11,
		-- Вопросы
		quests = {
			{quest = "Третий, по количеству жителей, город в ЮАР.", word = "кейптаун"},
			{quest = "Исследовтель Ливингстон открыл этот водопад.", word = "виктория"},
			{quest = "Изначально Нью-Йорк был назван в честь этого города.", word = "амстердам"},
		},
		-- Игроки
		party = {"player", "lyosha", "lena"},
		complexity = "hard",
		stars = {
			type = "score", star_1 = 500, star_2 = 1500, star_3 = 2000,
		}
	},
	{
		id = 12,
		-- Вопросы
		quests = {
			{quest = "Какой город располагается в двух частях света и ранее являлся столицей трех империй?", word = "стамбул"},
			{quest = "Название самого высокогорного в мире озера.", word = "балхаш"},
			{quest = "Какое самое холодное место в России?", word = "оймякон"},
		},
		-- Игроки
		party = {"player", "proskovia", "lyosha"},
		complexity = "hard",
		stars = {
			type = "score", star_1 = 500, star_2 = 1500, star_3 = 2500,
		}
	},
}

return M