-- Разбор csv файла
local insert = table.insert
local find = string.find
local sub = string.sub
local gsub = string.gsub
local gmatch = string.gmatch

local M = {}

local configs = {}

function M.load(config_id, filename, separator)
	local separator = separator or ","
	local rows = {}
	local row_ids = {}
	local row_key_values = {}
	local columns = {}
	local column_ids = {}
	local column_key_values = {}
	local matrix = {}

	-- Load file
	local csv_lines, error = sys.load_resource(filename)

	if error then
		pprint("ERROR: ", error)
		return false
	end

	-- Convert csv lines to indexed table
	-- Nabbed from: https://github.com/libremesh/pirania/blob/master/pirania/files/usr/lib/lua/voucher/utils.lua#L13
	local indexed_rows = {}
	local row_index = 1
	
	for csv_line in gmatch(csv_lines, "[^\r\n]+") do
		
		csv_line = csv_line .. separator        -- ending comma
		local row = {}        -- table to collect fields
		local fieldstart = 1
		repeat
			-- next field is quoted? (start with `"'?)
			if find(csv_line, '^"', fieldstart) then
				local a, c
				local i  = fieldstart
				repeat
					-- find closing quote
					a, i, c = find(csv_line, '"("?)', i+1)
				until c ~= '"'    -- quote not followed by quote?
				
				if not i then error('unmatched "') end
				local f = sub(csv_line, fieldstart+1, i-1)
				insert(row, (gsub(f, '""', '"')))
				fieldstart = find(csv_line, separator, i) + 1
			else                -- unquoted; find next comma
				local nexti = find(csv_line, separator, fieldstart)
				insert(row, sub(csv_line, fieldstart, nexti-1))
				fieldstart = nexti + 1
			end
		until fieldstart > #csv_line
		insert(indexed_rows, row)
	end

	-- Create reference tables from indexed table
	local column_count = #indexed_rows[1]
	for row_index=1, #indexed_rows do

		local row_cells = indexed_rows[row_index]
		local row_id = indexed_rows[row_index][1]

		for column_index=1, column_count do

			local cell = row_cells[column_index]

			if cell ~= "" then -- Ignore empty cells

				-- To boolean
				if cell == "TRUE" then
					cell = true
				elseif cell == "FALSE" then
					cell = false
				end

				-- To number
				local num = tonumber(cell) 
				if num then
					cell = num
				end

				local column_id = indexed_rows[1][column_index]

				-- Rows
				if row_index > 1 then
					if column_index == 1 then
						table.insert(row_ids, row_id)
					else

						-- Indexed values
						if not rows[row_id] then
							rows[row_id] = {}
						end
						table.insert(rows[row_id], cell)

						-- Key values
						if not row_key_values[row_id] then
							row_key_values[row_id] = {}
						end
						row_key_values[row_id][column_id] = cell

					end
				end

				-- Columns
				if column_index > 1 then
					if row_index == 1 then
						table.insert(column_ids, column_id)
					else

						-- Indexed values
						if not columns[column_id] then
							columns[column_id] = {}
						end
						table.insert(columns[column_id], cell)

						-- Key values
						if not column_key_values[column_id] then
							column_key_values[column_id] = {}
						end
						column_key_values[column_id][row_id] = cell


					end
				end

				-- Matrix
				if row_index > 1 and column_index > 1 then
					if not matrix[row_id] then
						matrix[row_id] = {}
					end
					matrix[row_id][column_id] = cell
				end

			end

		end

	end

	configs[config_id] = {
		rows = rows,
		row_ids = row_ids,
		row_key_values = row_key_values,
		columns = columns,
		column_ids = column_ids,
		column_key_values = column_key_values,
		matrix = matrix,
	}

	return true

end

function M.get_indexed_rows(config_id)

	return configs[config_id].rows

end

function M.get_indexed_row(config_id, row_id)

	local rows = M.get_indexed_rows(config_id)
	return rows[row_id]

end

function M.get_indexed_row_ids(config_id)

	return configs[config_id].row_ids

end

function M.get_row_key_values(config_id, row_id)

	return configs[config_id].row_key_values[row_id]

end

function M.get_indexed_columns(config_id)

	return configs[config_id].columns

end

function M.get_indexed_column(config_id, column_id)

	local columns = M.get_indexed_columns(config_id)
	return columns[column_id]

end

function M.get_indexed_column_ids(config_id)

	return configs[config_id].column_ids

end

function M.get_column_key_values(config_id, column_id)

	return configs[config_id].column_key_values[column_id]

end

function M.get_cell(config_id, row_id, cell_id)

	if configs[config_id].matrix[row_id] and configs[config_id].matrix[row_id][cell_id] then
		return configs[config_id].matrix[row_id][cell_id]
	end

end

function M.get_matrix(config_id)

	return configs[config_id].matrix

end

return M