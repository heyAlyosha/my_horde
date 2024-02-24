-- Динамическая отложенная загрузка атласов
local M = {}

local reszip = require "liveupdate_reszip.reszip"
local gui_loyouts = require "main.gui.modules.gui_loyouts"

-- Хранение уже загруженных и поставленных атласов
M.atlases_load = {}

-- Хранение уже загруженных и поставленных атласов
M.atlas_script_urls = {}

-- Храним очередь для отрисовки
M.render_stack = {}

-- Храним хеши для id
M.hash_ids = {}
M.hash_ids[hash("objects_full")] = "objects_full"
M.hash_ids[hash("prizes_mini")] = "prizes_mini"
M.hash_ids[hash("achieves")] = "achieves"
M.hash_ids[hash("notify")] = "notify"
M.hash_ids[hash("characteristics")] = "characteristics"
M.hash_ids[hash("preview")] = "preview"

-- Храним ресурсы атласов
M.resource_atlases = {}

M.hex_urls = {}

-- Атласа
function M.load(self, atlas_proxy_url, callback_finish, callback_progress)
	local zip_filename = sys.get_config("liveupdate_reszip.filename", "resources.zip")
	local zip_file_location = (html5 and zip_filename) or ("http://localhost:8080/" .. zip_filename)

	local missing_resources = collectionproxy.missing_resources(atlas_proxy_url)
	if next(missing_resources) ~= nil then
		assert(liveupdate, "`liveupdate` module is missing.")

		reszip.load_and_mount_zip(zip_file_location, {
			on_finish = callback_finish,
			on_progress = callback_progress
		})

	else
		if callback_finish then
			callback_finish(self, err)
		end
	end

end

-- Отрисовка элементов с подгруженными атласами
function M.script_is_init(self, resource_atlas, atlas_id_hash)
	local atlas_id = M.hash_ids[atlas_id_hash]
	M.atlases_load[atlas_id] = "loaded"
	M.resource_atlases[atlas_id] = resource_atlas

	for hex_url, v in pairs(M.render_stack) do
		local url = M.hex_urls[hex_url]
		msg.post(".", "add_texture_gui", {
			url = url, 
			atlas_id = atlas_id,
			resource_atlas = resource_atlas
		})
	end
end

-- Отрисовка элементов с подгруженными атласами
function M.render(self, atlas_id, callback)
	local url = msg.url()
	local hex_url = hash_to_hex(url.path)
	local atlas_proxy_url = "main:/live_update_atlas#"..atlas_id.."_collectionproxy"
	local script_proxy_url = msg.url(atlas_id.."_atlas", "go", "atlas_proxy_script")

	M.atlas_script_urls[script_proxy_url] = atlas_id

	M.render_stack[hex_url] = M.render_stack[hex_url] or {}
	M.hex_urls[hex_url] = url

	if not M.atlases_load[atlas_id] then
		-- Если атлас не загружен
		M.atlases_load[atlas_id] = "loading"
		-- Загружаем этот атлас
		M.load(self, atlas_proxy_url, function (self, err)			
			if not err then
				-- Атлас загружен
				--M.atlases_load[atlas_id] = "loaded"
				-- Отправляем сообщение для активации прокси
				msg.post("main:/live_update_atlas", "collection_proxy_activate", {url = atlas_proxy_url})
			end
		end)

		-- Добавляем функцию в очередь
		M.render_stack[hex_url] = M.render_stack[hex_url] or {}
		table.insert(M.render_stack[hex_url], {
			atlas_id = atlas_id,
			callback = callback
		})

	elseif M.atlases_load[atlas_id] == "loading" then
		-- Если атлас только загружается
		-- Добавляем функцию в очередь
		M.render_stack[hex_url] = M.render_stack[hex_url] or {}
		table.insert(M.render_stack[hex_url], {
			atlas_id = atlas_id,
			callback = callback
		})

	else
		-- Если всё в порядке 
		-- Проверяем добавлен ли атлас id
		self._live_update_atlas = self._live_update_atlas or {}
		self._live_update_atlas.add_atlases = self._live_update_atlas.add_atlases or {}
		if self._live_update_atlas.add_atlases[atlas_id] then
			-- Атлас добавлен и загружен 
			callback(self, atlas_id)
		else
			-- Атлас загружен, но не доабвлен
			table.insert(M.render_stack[hex_url], {
				atlas_id = atlas_id,
				callback = callback
			})

			msg.post("main:/live_update_atlas", "add_texture_gui", {
				url = url, 
				atlas_id = atlas_id,
				resource_atlas = resource_atlas
			})

		end

	end
end

-- Отрисовка элементов с подгруженными атласами с лоадером загрузки
function M.render_loader_gui(self, node_img, node_loader, atlas_id, callback)
	gui_loyouts.set_enabled(self, node_loader, true)
	gui_loyouts.set_enabled(self, node_img, false)
	gui.animate(node_loader, "rotation.z", 360, gui.EASING_LINEAR, 4, 0, nil, gui.PLAYBACK_LOOP_FORWARD)

	local new_callback = function (self, atlas_id)
		M.render(self, atlas_id, function (self, atlas_id)
			gui_loyouts.set_enabled(self, node_loader, false)
			gui_loyouts.set_enabled(self, node_img, true)
			gui.cancel_animation(node_loader, "rotation.z")

			callback(self, atlas_id)
		end)
	end

	M.render(self, atlas_id, new_callback)
end


-- Слушаем события в гуи
function M.on_message_gui(self, message_id, message, sender)
	local url = msg.url()
	local hex_url = hash_to_hex(url.path)

	if message_id == hash("live_update_add_texture") then
		-- Пришло сообщение, что добавлены ресурсы
		local atlas_id = message.atlas_id
		local stack = M.render_stack[hex_url] or {}

		for i = #stack, 1, -1 do
			local item = stack[i]

			self._live_update_atlas = self._live_update_atlas or {}
			self._live_update_atlas.add_atlases = self._live_update_atlas.add_atlases or {}
			self._live_update_atlas.add_atlases[item.atlas_id] = true

			

			if M.atlases_load[item.atlas_id] == "loaded" and self._live_update_atlas.add_atlases[item.atlas_id] then
				-- Если атлас загружен и добавлен
				item.callback(self, item.atlas_id)
				table.remove(M.render_stack[hex_url], i)

			elseif M.atlases_load[item.atlas_id] == "loaded" and not self._live_update_atlas.add_atlases[item.atlas_id] then
				-- Если атлас загружен и но не добавлен
				msg.post("main:/live_update_atlas", "add_texture_gui", {
					url = url, 
					atlas_id = item.atlas_id,
					resource_atlas = M.resource_atlases[item.atlas_id]
				})
				break
	
			end
		end
	end
end

-- Удаление компонента гуи
function M.on_final_gui(self)
	local url = msg.url()
	local hex_url = hash_to_hex(url.path)

	M.render_stack[hex_url] = nil
end

return M