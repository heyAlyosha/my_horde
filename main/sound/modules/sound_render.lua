-- 
local M = {}
local sound_content = require "main.content.sound.sound_content"
local storage_player = require "main.storage.storage_player"
local scream_zombie = {id = hash("scream_zombie"), dist = 175, volume = 0.9, max_count = 4, sounds = {}}
local scream_human = {id = hash("scream_human"), dist = 175, volume = 1, max_count = 4, sounds = {}}
local items = {id = hash("items"), dist = 175, volume = 1, max_count = 4, sounds = {}}
local zombie_death = {id = hash("zombie_death"), dist = 175, volume = 1, max_count = 2, sounds = {}}
local move_step = { 
	id = hash("move_step"), 
	dist = 300, -- Расстояние слышимости звука
	volume = 1, -- Изменение стандартной громкости
	max_count = 12, -- максимальное кол-во одновременно проигрываемых звуков
	sounds = {}
}
M.url_obj = "live_update_sound:/sound"
M.play_music = {}

M.params = {
	move_step = move_step,
	necrone_step = move_step,
	-- Настройки
	infection = {id = hash("infection"), dist = 300, volume = 1, max_count = 4, sounds = {}},
	buy_zombie = {id = hash("buy_zombie"), dist = 300, volume = 1, max_count = 2, sounds = {}},
	screem_walk_woman = scream_human,
	screem_run_woman = scream_human,
	screem_walk_man = scream_human,
	screem_run_man = scream_human,
	zombie_screem_woman = scream_zombie,
	zombie_screem_man = scream_zombie,
	zombie_screem_alien = scream_zombie,
	zombie_screem_ufo = scream_zombie,
	add_gold = items,
	booklet = items,
	papper = items,
	trofey = items,
	zombie_death = zombie_death
}

-- Функция проверки колличества тукущих звуков
function M.is_play_count(sound_id)
	local param_sound = M.params[sound_id]
	if not param_sound then
		return true
	else
		return #param_sound.sounds < param_sound.max_count
	end
end

-- Остановка звука для объекта
function M.stop_sound_object(sound_id, url_object)
	local param_sound = M.params[sound_id]
	if param_sound and param_sound.sounds then
		for i = 1, #param_sound.sounds do
			local item = param_sound.sounds[i]
			if item and item.url_object == url_object then
				table.remove(param_sound.sounds, i)
				i = i - 1
			end
		end
	end
end

-- Очистка всех типов звуков от объекта
function M.clear_all_sounds_from_object(url_object)
	for sound_id, param_sound in pairs(M.params) do
		if param_sound.sounds then
			M.stop_sound_object(sound_id, url_object)
		end
	end
end

-- Очистка всех типов звуков
function M.clear_all_sounds()
	--[[
	for k, param_sound in pairs(M.params) do
		if param_sound.sounds then
			for k_s, item in pairs(param_sound.sounds) do
				param_sound.sounds[k_s] = nil
			end
		end
	end
	--]]
end


-- Проигрывание звука
function M.play(sound_id, url_object, is_single)
	if not M.load_files then
		return
	end
	local sound_name = sound_content.get_random(sound_id)

	storage_player.settings.volume_effects = storage_player.settings.volume_effects or 0

	if storage_player.settings.volume_effects > 0 and sound_name then
		-- Находим, есть ли настройки
		local param_sound = M.params[sound_id]

		-- Yаходим сторону откуда пришёл звук
		local pan = 0
		local volume_edit = 1 -- Усиление звука
		if param_sound then
			volume_edit = param_sound.volume
		end
		local volume_dist = 1
		if url_object and storage_player.user_go_url then
			local position_object = go.get_position(url_object)

			local position_player = go.get_position(storage_player.user_go_url)
			local dir_line = position_object - position_player
			local distance = vmath.length(dir_line)
			-- Находим сторону, откуда доносится звук
			pan = vmath.normalize(dir_line).x

			-- Находим дальность и громкость
			if param_sound then
				volume_dist = 1 - distance / param_sound.dist

				if volume_dist > 0.9 and volume_dist < 1 then
					--volume_dist = 1
				elseif volume_dist < 0.2 or volume_dist > 1 then
					return
				end
			end
		end

		-- Итоговая громкость
		local result_volume = storage_player.settings.volume_effects * volume_edit * volume_dist
		if sound_name then
			if not param_sound then
				-- Если нет параметров, то просто 
				if is_single and M.play_music[sound_id] then
					return
				end

				M.play_music[sound_id] = sound.play("live_update_sound:/sound#"..sound_name, {gain = result_volume, pan = pan}, function (self, message_id, message, sender)
					if message_id == hash("sound_done") and message.play_id == M.play_music[sound_id] then
						M.play_music[sound_id] = nil
					end
				end)

			else
				-- смотрим не забито 
				if M.is_play_count(sound_id) then
					local item = {
						id = sound.play("live_update_sound:/sound#"..sound_name, {gain = result_volume, pan = pan}, function (self, message_id, message, sender)
							for i, v in ipairs(param_sound.sounds) do
								if v.id == message.play_id then
									table.remove(param_sound.sounds, i)
								end
							end
						end),
						volume = result_volume,
						sound_name = sound_name,
						url_object = url_object
					}
					table.insert(param_sound.sounds, item)
				
				elseif result_volume == 1 then
					-- Если громоксть 1, то передаём её на первый план

					-- Удаляем первый звук (самый старый)
					sound.stop("live_update_sound:/sound#"..param_sound.sounds[1].sound_name)
					table.remove(param_sound.sounds, 1)

					-- Добавляем и запускаем новый
					local item = {
						id = sound.play("live_update_sound:/sound#"..sound_name, {gain = result_volume, pan = pan}, function (self, message_id, message, sender)
							for i, v in ipairs(param_sound.sounds) do
								if v.id == message.play_id then
									table.remove(param_sound.sounds, i)
								end
							end
						end),
						volume = result_volume,
						sound_name = sound_name,
					}
					table.insert(param_sound.sounds, item)
				end	
			end
		end
	end
end

return M