-- Модуль управлениея цветом для игрока
local M = {}

M.colors = {
	ivory = {
		hp_img = "HpLine-ivory",
		color_rgb = vmath.vector3(255,255,240),
		color = nil
	},
	blue = {
		hp_img = "HpLine-blue",
		color_rgb = vmath.vector3(0,0,255),
		color = nil
	},
	brown = {
		hp_img = "HpLine-brown",
		color_rgb = vmath.vector3(150,75,0),
		color = nil
	},
	green = {
		hp_img = "HpLine-green",
		color_rgb = vmath.vector3(0,128,0),
		color = nil
	},
	red = {
		hp_img = "HpLine-red",
		color_rgb = vmath.vector3(255,0,0),
		color = nil
	},
	yellow = {
		hp_img = "HpLine-yellow",
		color_rgb = vmath.vector3(255,255,0),
		color = nil
	},
	beige = {
		hp_img = "HpLine-beige",
		color_rgb = vmath.vector3(245,245,220),
		color = nil
	},
	wheat = {
		hp_img = "HpLine-wheat",
		color_rgb = vmath.vector3(245,222,179),
		color = nil
	},
	khaki = {
		hp_img = "HpLine-khaki",
		color_rgb = vmath.vector3(240,230,140),
		color = nil
	},
	golden = {
		hp_img = "HpLine-golden",
		color_rgb = vmath.vector3(255,215,0),
		color = nil
	},
	coral = {
		hp_img = "HpLine-coral",
		color_rgb = vmath.vector3(255,127,80),
		color = nil
	},
	salmon = {
		hp_img = "HpLine-salmon",
		color_rgb = vmath.vector3(250,128,114),
		color = nil
	},
	pink = {
		hp_img = "HpLine-pink",
		color_rgb = vmath.vector3(255,0,127),
		color = nil
	},
	fuchsia = {
		hp_img = "HpLine-fuchsia",
		color_rgb = vmath.vector3(255,0,255),
		color = nil
	},
	lavender = {
		hp_img = "HpLine-lavender",
		color_rgb = vmath.vector3(230,230,250),
		color = nil
	},
	plum = {
		hp_img = "HpLine-plum",
		color_rgb = vmath.vector3(142,69,133),
		color = nil
	},
	indigo = {
		hp_img = "HpLine-indigo",
		color_rgb = vmath.vector3(75,0,130),
		color = nil
	},
	maroon = {
		hp_img = "HpLine-maroon",
		color_rgb = vmath.vector3(176,48,96),
		color = nil
	},
	crimson = {
		hp_img = "HpLine-crimson",
		color_rgb = vmath.vector3(220,20,60),
		color = nil
	},
	silver = {
		hp_img = "HpLine-silver",
		color_rgb = vmath.vector3(192,192,192),
		color = nil
	},
	gray = {
		hp_img = "HpLine-gray",
		color_rgb = vmath.vector3(128,128,128),
		color = nil
	},
	charcoal = {
		hp_img = "HpLine-charcoal",
		color_rgb = vmath.vector3(54,69,79),
		color = nil
	},
	pea = {
		hp_img = "HpLine-pea",
		color_rgb = vmath.vector3(64,75,13),
		color = nil
	},
	olive = {
		hp_img = "HpLine-olive",
		color_rgb = vmath.vector3(128,128,0),
		color = nil
	},
	lime = {
		hp_img = "HpLine-lime",
		color_rgb = vmath.vector3(0,255,0),
		color = nil
	},
	teal = {
		hp_img = "HpLine-teal",
		color_rgb = vmath.vector3(0,128,128),
		color = nil
	},
	navy_blue = {
		hp_img = "HpLine-navy-blue",
		color_rgb = vmath.vector3(0,0,128),
		color = nil
	},
	royal_blue = {
		hp_img = "HpLine-royal-blue",
		color_rgb = vmath.vector3(0,35,102),
		color = nil
	},
	azure = {
		hp_img = "HpLine-azure",
		color_rgb = vmath.vector3(0,127,255),
		color = nil
	},
	ciyan = {
		hp_img = "HpLine-ciyan",
		color_rgb = vmath.vector3(0, 255, 255),
		color = nil
	},
	aquamarine = {
		hp_img = "HpLine-aquamarine",
		color_rgb = vmath.vector3(127,255,212),
		color = nil
	},
	orange = {
		hp_img = "HpLine-orange",
		color_rgb = vmath.vector3(255,165,0),
		color = nil
	},
	magenta = {
		hp_img = "HpLine-magenta",
		color_rgb = vmath.vector3(255,0,255),
		color = nil
	},
	white = {
		hp_img = "HpLine-white",
		color_rgb = vmath.vector3(255,255,255),
		color = nil
	},
	human = {
		hp_img = nil,
		color_rgb = vmath.vector3(255,207,171),
		color = nil
	},
	light_gray = {
		hp_img = "HpLine-gray",
		color_rgb = vmath.vector3(237,237,237),
		color = nil
	}
}

M.colors_code = {
	code_1 = "ivory",
	code_2 = "blue",
	code_3 = "brown",
	code_4 = "green",
	code_5 = "red",
	code_6 = "yellow",
	code_7 = "beige",
	code_8 = "wheat",
	code_9 = "khaki",
	code_10 = "golden",
	code_11 = "coral",
	code_12 = "salmon",
	code_13 = "pink",
	code_14 = "fuchsia",
	code_15 = "lavender",
	code_16 = "plum",
	code_17 = "indigo",
	code_18 = "maroon",
	code_19 = "crimson",
	code_20 = "silver",
	code_21 = "gray",
	code_22 = "charcoal",
	code_23 = "pea",
	code_24 = "olive",
	code_25 = "lime",
	code_26 = "teal",
	code_27 = "navy_blue",
	code_28 = "royal_blue",
	code_29 = "azure",
	code_30 = "ciyan",
	code_31 = "aquamarine",
	code_32 = "orange",
	code_33 = "magenta",
	code_34 = "white",
	сode_35 = "human",
	code_36 = "light_gray"
}

-- Получение данных по цвету
function M.get_data(name)
	local color_data = M.colors[name]

	if not color_data.color then
		color_data.color = vmath.vector3(color_data.color_rgb.x / 255, color_data.color_rgb.y / 255, color_data.color_rgb.z / 255)
	end

	return color_data
end

-- Получение цвета по коду
function M.get_code(code)
	local color_name = M.colors_code["code_"..code]

	local data = M.get_data(color_name)
	data.name = color_name

	return data
end

-- Получение инфы по названию цвета
function M.get_name(name)
	local color_name = name

	if color_name == "navy-blue" then
		color_name = "navy_blue"

	elseif color_name == "royal-blue" then
		color_name = "royal_blue"

	end

	local data = M.get_data(color_name)
	data.name = color_name

	return data
end

return M