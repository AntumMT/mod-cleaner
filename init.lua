
--- Cleaner
--
--  @topic tools


cleaner = {}
cleaner.modname = core.get_current_modname()
cleaner.modpath = core.get_modpath(cleaner.modname)

local cleaner_debug = core.settings:get_bool("enable_debug_mods", false)

function cleaner.log(lvl, msg)
	if lvl == "debug" and not cleaner_debug then return end

	if lvl and not msg then
		msg = lvl
		lvl = nil
	end

	msg = "[" .. cleaner.modname .. "] " .. msg
	if lvl == "debug" then
		msg = "[DEBUG] " .. msg
		lvl = nil
	end

	if not lvl then
		core.log(msg)
	else
		core.log(lvl, msg)
	end
end

local aux = dofile(cleaner.modpath .. "/misc_functions.lua")

-- initialize world file
aux.update_world_data()


local scripts = {
	"settings",
	"api",
	"chat",
	"entities",
	"nodes",
	"items",
	"ores",
}

for _, script in ipairs(scripts) do
	dofile(cleaner.modpath .. "/" .. script .. ".lua")
end


local S = core.get_translator(cleaner.modname)


local sound_handle

--- Master Pencil
--
--  @tool cleaner:pencil
--  @img cleaner_pencil.png
--  @privs server
core.register_tool(cleaner.modname .. ":pencil", {
	description = S("Master Pencil"),
	inventory_image = "cleaner_pencil.png",
	liquids_pointable = true,
	on_use = aux.tool.on_use,
	on_secondary_use = aux.tool.on_secondary_use,
	on_place = aux.tool.on_place,
})

core.register_tool(cleaner.modname .. ":pencil_1", {
	description = S("Master Pencil"),
	inventory_image = "cleaner_pencil.png^[transformFXFY",
	liquids_pointable = true,
	groups = {not_in_creative_inventory=1},
	on_use = aux.tool.on_use,
	on_secondary_use = aux.tool.on_secondary_use,
	on_place = aux.tool.on_place,
})
