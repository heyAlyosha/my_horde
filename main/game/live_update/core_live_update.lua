-- Динамическая отложенная загрузка медиа
local M = {}

local reszip = require "liveupdate_reszip.reszip"




local function on_finish(self, err)
	print("on_finish")
end

local function on_progress (self, loaded, total)
	print("on_progress", progress)
end

function M.load(self, url, callback_finish, callback_progress)
	local zip_filename = sys.get_config("liveupdate_reszip.filename", "resources.zip")
	local zip_file_location = (html5 and zip_filename) or ("http://localhost:8080/" .. zip_filename)
	--local excluded_proxy_url = "/level2#collectionproxy"

	local missing_resources = collectionproxy.missing_resources(url)
	if next(missing_resources) ~= nil then
		print("Some resources are missing, so download and mount the resources archive...")
		assert(liveupdate, "`liveupdate` module is missing.")

		reszip.load_and_mount_zip(zip_file_location, {
			on_finish = callback_finish,
			on_progress = callback_progress
		})

	else
		-- All resources exist, so load the level:
		print("Resources are already loaded. Let's load level 2!")
		if callback_finish then
			callback_finish(self, err)
		end
	end
	
end

return M