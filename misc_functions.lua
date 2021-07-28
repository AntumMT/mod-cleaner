
local S = core.get_translator(cleaner.modname)


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

local tool = {
	modes = {
		erase = true,
		write = true,
		swap = true,
	},
}

tool.set_mode = function(self, stack, mode, pname)
	local iname = stack:get_name()

	if not self.modes[mode] then
		if pname then
			core.chat_send_player(pname, iname .. ": " .. S("unknown mode: @1", mode))
		end
		cleaner.log("warning", iname .. ": unknown mode: " .. mode)
		return stack
	end

	--[[ FIXME: want to flip item image when mode is set to "erase"
	local new_item = table.copy(core.registered_nodes[iname])
	if mode == "erase" then
		new_item.inventory_image = "cleaner_pencil.png^[transformFXFY"
	else
		new_item.inventory_image = "cleaner_pencil.png"
	end

	local new_stack = ItemStack(new_item)
	]]

	local imeta = stack:get_meta()
	imeta:set_string("mode", mode)

	if pname then
		core.chat_send_player(pname, iname .. ": "
			.. S("mode set to: @1", imeta:get_string("mode")))
	end

	return stack
end

tool.set_node = function(self, stack, node, pname)
	local imeta = stack:get_meta()
	imeta:set_string("node", node)

	if pname then
		core.chat_send_player(pname, stack:get_name() .. ": "
			.. S("node set to: @1", imeta:get_string("node")))
	end

	return stack
end


return {
	clean_duplicates = clean_duplicates,
	get_world_data = get_world_data,
	update_world_data = update_world_data,
	tool = tool,
}
