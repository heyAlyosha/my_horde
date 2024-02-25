-- Отображение элементов гуи
local M = {}

M.gui_components = {"interface", "main_menu", "catalog_company", "catalog_levels", "modal_pause", "game_constructor", "game_family_shop", "modal_result_single", "modal_settings"}

-- Показ Гуи компонентов
function M.visible_components(self, components_visible, components_data)
	components_visible = components_visible or {}
	components_data = components_data or {}

	for i, component_id in ipairs(M.gui_components) do
		local msg_data  = {
			id = component_id, 
			type = hash("animated_close"), 
			visible = components_visible[component_id] ~= nil,
		}

		if components_data[component_id] then
			for k, item in pairs(components_data[component_id]) do
				msg_data[k] = item
			end
		end

		msg.post("/loader_gui", "visible", msg_data)

	end

	
end

return M