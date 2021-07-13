
--- Cleans duplicate entries from indexed table.
--
--  @local
--  @function clean_duplicates
--  @tparam table t
--  @treturn table
local function clean_duplicates(t)
	local tmp = {}
	for _, v in ipairs(t) do
		tmp[v] = true
	end

	t = {}
	for k in pairs(tmp) do
		table.insert(t, k)
	end

	return t
end

local world_file = core.get_worldpath() .. "/cleaner.json"

local function get_world_data()
	local wdata = {}
	local buffer = io.open(world_file, "r")
	if buffer then
		wdata = core.parse_json(buffer:read("*a"))
		buffer:close()
	end

	local rem_types = {"entities", "nodes", "ores",}
	local rep_types = {"items", "nodes",}

	for _, t in ipairs(rem_types) do
		wdata[t] = wdata[t] or {}
		wdata[t].remove = wdata[t].remove or {}
	end

	for _, t in ipairs(rep_types) do
		wdata[t] = wdata[t] or {}
		wdata[t].replace = wdata[t].replace or {}
	end

	return wdata
end

local function update_world_data(t, data)
	local wdata = get_world_data()
	if t and data then
		wdata[t].remove = data.remove
		wdata[t].replace = data.replace
	end

	local json_string = core.write_json(wdata, true):gsub("\"remove\" : null", "\"remove\" : []")
		:gsub("\"replace\" : null", "\"replace\" : {}")

	local buffer = io.open(world_file, "w")
	if buffer then
		buffer:write(json_string)
		buffer:close()

		return true
	end

	return false
end


return {
	clean_duplicates = clean_duplicates,
	get_world_data = get_world_data,
	update_world_data = update_world_data,
}
