--[[ Cleaner mod
	License: MIT
]]


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


local scripts = {
	"entities",
	"nodes",
}

for _, script in ipairs(scripts) do
	dofile(cleaner.modpath .. "/" .. script .. ".lua")
end
