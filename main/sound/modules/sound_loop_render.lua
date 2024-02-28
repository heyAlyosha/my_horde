-- Модуль проигрывания цикличного звука
local M = {}

local sound_content = require "main.content.sound.sound_content"
local storage_player = require "main.storage.storage_player"
--local table_functions = require "main.global.table_functions"

local move_step = { 
	dist = 300, -- Расстояние слышимости звука
	volume = 1, -- Изменение стандартной громкости
	max_count = 6, -- максимальное кол-во одновременно проигрываемых звуков
	sounds = {}
}

local spiders_step = { 
	dist = 300, -- Расстояние слышимости звука
	volume = 1, -- Изменение стандартной громкости
	max_count = 6, -- максимальное кол-во одновременно проигрываемых звуков
	sounds = {}
}
M.params = {
	terminator_step = move_step,
	spiders_step = spiders_step,
}

-- Храним текущие воспроизводимые звуки
M.sounds_loop_play = {}

-- Функция получения громкости
function M.get_volume(sound_id, url_object, current_player, params)
	local param_sound = params or M.params[sound_id]

	local position_object = go.get_position(url_object)
	local position_player = go.get_position(storage_player.user_go_url)
	local dir_line = position_object - position_player
	local distance = vmath.length(dir_line)
	local volume_dist = 1
	local pan = 0

	if not url_object or current_player or position_object == position_player or url_object == storage_player.user_go_url then
		return {volume = volume_dist * storage_player.settings.volume_effects, pan = pan}
	end

	if distance == 0 then
		pan = 0
	else
		pan = vmath.normalize(dir_line).x
	end

	-- Находим дальность и громкость
	if param_sound then
		volume_dist = 1 - distance / param_sound.dist

		if volume_dist < 0.2 or volume_dist > 1 then
			volume_dist = 0
		end
	end

	return {volume = volume_dist * storage_player.settings.volume_effects, pan = pan}
end

-- Функция проверки колличества тукущих звуков
function M.is_play_count(sound_id, object_url, go_id, current_player)
	local param_sound = M.params[sound_id]
	if current_player or not param_sound then
		return true
	else
		-- Если есть
		local count = table_functions.get_count(param_sound.sounds)
		return count < param_sound.max_count
	end
end

-- Остановка цикличного звука
function M.stop(sound_type)
	local item = M.sounds_loop_play[sound_type]

	if item then
		sound.stop("/sound_loop#"..item.sound_name)
		M.sounds_loop_play[sound_type] = nil
	end
end

-- Остановка цикличного звука
function M.set_volume(volume)
	for k, item in pairs(M.sounds_loop_play) do
		if k ~= "bg_sound" then
			item.volume = volume
			item.pause = (item.volume == 0)

			sound.set_gain("main:/sound_loop#"..item.sound_name, item.volume)
			sound.pause("main:/sound_loop#"..item.sound_name, item.pause)
		end
	end
end

-- Остановка цикличного звука
function M.set_volume_bg(volume)
	for k, item in pairs(M.sounds_loop_play) do
		if k == "bg_sound" then
			item.volume = volume
			item.pause = (item.volume == 0)

			sound.set_gain("main:/sound_loop#"..item.sound_name, item.volume)
			sound.pause("main:/sound_loop#"..item.sound_name, item.pause)
		end
	end
end

-- Проигрывание звука
function M.play(sound_type, sound_id, url_object)
	local sound_name = sound_content.get(sound_id)

	-- Смотрим вопроизводится ли уже такой тип звука
	for k, item in pairs(M.sounds_loop_play) do
		if k == sound_type then
			-- Если звук не такой, как сейчас проигрывается останавливаем его
			if item.sound_id ~= sound_id then
				M.stop(sound_type)
			else
				return
			end
		end
	end

	local result_volume = storage_player.settings.volume_effects

	M.sounds_loop_play[sound_type] = {
		sound_name = sound_name,
		sound_id = sound_id,
		sound_play_id = sound.play("main:/sound_loop#"..sound_name, {gain = result_volume, pan = pan}),
		url_object = url_object,
		volume = result_volume,
		pause = (result_volume == 0)
	}

	sound.pause("main:/sound_loop#"..sound_name, M.sounds_loop_play[sound_type].pause)
end

return M