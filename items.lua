
local misc = dofile(cleaner.modpath .. "/misc_functions.lua")

-- populate nodes list from file in world path
local i_list = {replace={}}
local i_path = core.get_worldpath() .. "/clean_items.json"
local i_file = io.open(i_path, "r")

if i_file then
	local data_in = core.parse_json(i_file:read("*a"))
	i_file:close()
	if data_in then
		i_list = data_in
	end
end

-- update json file with any changes
i_file = io.open(i_path, "w")
if i_file then
	local data_out = core.write_json(i_list, true)

	data_out = data_out:gsub("\"replace\" : null", "\"replace\" : {}")

	i_file:write(data_out)
	i_file:close()
end

-- register actions for after server startup
core.after(0, function()
	for i_old, i_new in pairs(i_list.replace) do
		cleaner.log("action", "replacing item \"" .. i_old .. "\" with \"" .. i_new .. "\"")

		if not core.registered_items[i_old] then
			cleaner.log("info", "\"" .. i_old .. "\" not registered, not unregistering")
		else
			cleaner.log("warning", "overriding registered item \"" .. i_old .. "\"")

			core.unregister_item(i_old)
			if core.registered_items[i_old] then
				cleaner.log("error", "could not unregister \"" .. i_old .. "\"")
			end
		end

		if not core.registered_items[i_new] then
			cleaner.log("warning", "adding alias for unregistered item \"" .. i_new .. "\"")
		end

		core.register_alias(i_old, i_new)
		if core.registered_aliases[i_old] == i_new then
			cleaner.log("info", "registered alias \"" .. i_old .. "\" for \"" .. i_new .. "\"")
		else
			cleaner.log("error", "could not register alias \"" .. i_old .. "\" for \"" .. i_new .. "\"")
		end
	end
end)
