
local print, error, type, ipairs
if import then
	print = import("print")
	error = import("error")
	type = import("type")
	ipairs = import("ipairs")
end


project = "Cleaner"
title = "Cleaner mod for Minetest"
format = "markdown"
not_luadoc=true
boilerplate = false
style = true

file = {
	"settings.lua",
	"api.lua",
	"chat.lua",
	"tools.lua",
}

new_type("chatcmd", "Chat Commands")
new_type("setting", "Settings")
new_type("tool", "Tools")
new_type("json", "JSON Configurations")

custom_tags = {
	{
		"privs",
		title = "Required Privileges",
	},
	-- settings
	{
		"settype",
		title = "Setting Type",
		hidden = true,
	},
	{
		"default",
		title = "Default Value",
		hidden = true,
	},
	-- craft items/tools
	{
		"img",
		title = "Image",
		format = function(value)
			return "<img src=\"../../../textures/" .. value .. "\" style=\"width:32px; height:32px;\" />"
		end,
	},
}


local registered = {
	settings = {},
}

local function format_setting_tag(desc, value)
	return "\n- <span style=\"font-size:80%;\">`" .. desc .. ":`</span> `" .. value .. "`"
end

local function setting_handler(item)
	print("\nsetting_handler: " .. item.name)

	if not ipairs or not type then
		return item
	end

	local tags = {
		{"settype", "type"},
		{"default"},
		{"min", "minimum value"},
		{"max", "maximum value"},
	}

	local def = {
		["settype"] = format_setting_tag("type", "string"),
	}

	for _, t in ipairs(tags) do
		local name = t[1]
		local desc = t[2]
		if not desc then desc = name end

		local value = item.tags[name]
		if type(value) == "table" then
			if #value > 1 then
				local msg = item.file.filename .. " (line " .. item.lineno
					.. "): multiple instances of tag \"" .. name .. "\" found"
				if error then
					error(msg)
				elseif print then
					print("WARNING: " .. msg)
				end
			end

			if value[1] then
				def[name] = format_setting_tag(desc, value[1])
			end
		end
	end

	item.description = item.description .. "\n\n**Definition:**\n" .. def.settype
	for _, t in ipairs({def.default, def.min, def.max}) do
		if t then
			item.description = item.description .. t
		end
	end

	registered.settings[item.name] = true

	return item
end

function custom_display_name_handler(item, default_handler)
	if item.type == "setting" and not registered.settings[item.name] then
		item = setting_handler(item)
	end

	if item then
		return default_handler(item)
	end
end
