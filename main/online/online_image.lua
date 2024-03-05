-- Функция загрузки картинок
local M = {}

M.images = {}
M.go_images = {}
M.responses_cache = {}
M.flip_gui = false

-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"

function M.is_error_request(self, response)
	return response.status ~= 200 and response.status ~= 304
end

-- Загрузка и кеширпование картинок по ссылке
function M.load(self, url, callback)
	if not M.responses_cache[url] then
		http.request(url, "GET", function(self, id, response)
			local error = M.is_error_request(self, response)

			if not error then
				M.responses_cache[url] = response.response
			end

			if callback then
				callback(self, response.response, error)
			end
		end)
	else
		local response = M.responses_cache[url]
		callback(self, response)
	end
end

-- Запись текстуры в гуи
function M.set_texture(self, node, url)
	M.load(self, url, function (self, response, error)
		if not error then
			local img = M.images[url] or image.load(response)
			--M.images[url] = img

			gui.new_texture(url, img.width, img.height, img.type, img.buffer, M.flip_gui)
			gui_loyouts.set_texture(self, node, url)
		end
	end)
end

function M.set_texture_sprite(self, sprite_url, url)
	M.load(self, url, function (self, response, error)
		if not error then
			M.flip_gui = true
			M.go_images[url] = nil
			if not M.go_images[url] then
				M.go_images[url] = imageloader.load{data = response}

				local texture_path = go.get(sprite_url, "texture0")
				
				resource.set_texture(texture_path, M.go_images[url].header, M.go_images[url].buffer)
			else
				local image_resource = M.go_images[url]
				resource.set_texture( go.get(sprite_url, "texture0"), image_resource.header, image_resource.buffer )
			end
		end
	end)
end

return M