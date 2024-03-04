-- Функции для path
local M = {}

function M.get_path(self, position_target)
	local position = go.get_position()
	--print("position", position)
	local tile_x, tile_y = astar_utils:screen_to_coords(position.x, position.y)
	local tile_x_to, tile_y_to = astar_utils:screen_to_coords(position_target.x, position_target.y)

	self.debug_lines_to_target = {from = position, to = position_target}
	self.debug_lines_to_tile = {}

	result, path_size, totalcost, path =
	astar.solve(tile_x, tile_y, tile_x_to, tile_y_to)

	if result == astar.SOLVED then
		if self.type == 1 then
			totalcost = math.floor(self.totalcost)
		end

		--pprint(result, path_size, totalcost, path)
		for i = 1, #path do
			
			local item = path[i]
			local to_x, to_y = astar_utils:coords_to_screen(item.x,item.y)
			
			if i == 1 then
				table.insert(self.debug_lines_to_tile, {from = position, to = vmath.vector3(to_x, to_y, 0)})
			else
				local prev_item = path[i - 1]
				from_x, from_y = astar_utils:coords_to_screen(prev_item.x,prev_item.y)
				table.insert(self.debug_lines_to_tile, {from = vmath.vector3(from_x, from_y, 0), to = vmath.vector3(to_x, to_y, 0)})
			end
		end
		return result, path_size, totalcost, path

	elseif self.result == astar.NO_SOLUTION then
		return false, self.result

		--[[
		self.near_result, self.near_size, self.nears = astar.solve_near(self.tile_x, self.tile_y, 10)

		local temp_tiles = {}

		for t = 1, s.target_count do
			for n = 1, #self.nears do
				if s.targets[t].x == self.nears[n].x and s.targets[t].y == self.nears[n].y then
					table.insert(temp_tiles, self.nears[n])
				end
			end
		end

		self.target = temp_tiles[rnd.range(1, #temp_tiles)]
		get_path(self, true)
		--]]

	elseif self.result == astar.START_END_SAME then
		return false, self.result

	end
end

return M