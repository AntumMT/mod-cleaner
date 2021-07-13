
local aux = dofile(cleaner.modpath .. "/misc_functions.lua")

-- populate items list from file in world path
local items_data = aux.get_world_data().items


-- START: backward compat

local i_path = core.get_worldpath() .. "/clean_items.json"
local i_file = io.open(i_path, "r")

if i_file then
	cleaner.log("action", "found deprecated clean_items.json, updating")

	local data_in = core.parse_json(i_file:read("*a"))
	i_file:close()
	if data_in and data_in.replace then
		for k, v in pairs(data_in.replace) do
			if not items_data.replace[k] then
				items_data.replace[k] = v
			end
		end
	end

	-- don't read deprecated file again
	os.rename(i_path, i_path .. ".old")
end

-- END: backward compat


aux.update_world_data("items", items_data)

for i_old, i_new in pairs(items_data.replace) do
	cleaner.register_item_replacement(i_old, i_new)
end

-- register actions for after server startup
core.register_on_mods_loaded(function()
	for i_old, i_new in pairs(cleaner.get_replace_items()) do
		cleaner.log("action", "registering item \"" .. i_old .. "\" to be replaced with \"" .. i_new .. "\"")

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
