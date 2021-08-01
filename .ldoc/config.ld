
local dofile, print, error, type, table, ipairs, string, tostring
if import then
	dofile = import("dofile")
	print = import("print")
	error = import("error")
	type = import("type")
	table = import("table")
	ipairs = import("ipairs")
	string = import("string")
	tostring = import("tostring")
end


project = "Cleaner"
title = "Cleaner mod for Minetest"
format = "markdown"
not_luadoc=true
boilerplate = false
style = true
icon = "textures/cleaner_pencil.png"

file = {
	"settings.lua",
	"api.lua",
	"chat.lua",
	"tools.lua",
	".ldoc/config.luadoc",
}

new_type("chatcmd", "Chat Commands")
new_type("setting", "Settings")
new_type("tool", "Tools")
new_type("json", "JSON Configurations")


local function video_frame(src)
	return '<iframe width="560" height="315" src="' .. src
		.. '" title="Video Player" frameborder="0"'
		.. ' allow="fullscreen;"></iframe>'
end


local tags
tags, custom_tags = dofile(".ldoc/tags.ld")


-- START: handling items to prevent re-parsing

local registered_items = {}

local function is_registered(item)
	if not registered_items[item.type] then return false end

	for _, tbl in ipairs(registered_items[item.type]) do
		if item == tbl then
			return true
		end
	end

	return false
end

local function register(item)
	if not registered_items[item.type] then
		registered_items[item.type] = {}
	end

	if not is_registered(item) then
		table.insert(registered_items[item.type], item)
	end
end

-- END:


local function format_setting_tag(desc, value)
	return "\n- <span style=\"font-size:80%;\">`" .. desc .. ":`</span> `" .. value .. "`"
end

local function setting_handler(item)
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

	return item
end

local function chatcmd_handler(item)
	for _, p in ipairs(item.params) do
		if item.modifiers.param[p].opt then
			item.name = item.name .. " [" .. p .. "]"
		else
			item.name = item.name .. " &lt;" .. p .. "&gt;"
		end
	end

	if #item.params > 0 then
		local pstring = "### Parameters:\n"
		for k, param in pairs(item.params) do
			if type(k) == "number" then
				local value = item.params.map[param]

				pstring = pstring .. '\n- <span class="parameter">'
					.. param .. '</span>'

				local modifiers = item.modifiers.param[param]
				if modifiers and modifiers.type then
					pstring = pstring .. ' <span class="types"><span class="type">`' .. modifiers.type .. '`</span></span>'
				end

				if value then
					pstring = pstring .. value
				end

				if modifiers and modifiers.opt then
					pstring = pstring .. " *(optional)*"
				end
			end
		end

		item.description = item.description .. "\n\n" .. pstring
		-- clear parameter list
		item.params = {}
	end

	return item
end

function custom_display_name_handler(item, default_handler)
	if not is_registered(item) then
		if item.type == "setting" then
			item = setting_handler(item)
		elseif item.type == "chatcmd" then
			item = chatcmd_handler(item)
		end

		local parse_tags = {"priv", "note"}
		for _, pt in ipairs(parse_tags) do
			local tvalues = item.tags[pt]
			if tvalues then
				local tstring = ""

				local title = tags.get_title(pt)
				if title then
					tstring = tstring .. "\n\n### " .. title .. ":\n"
				end

				for _, tv in ipairs(tvalues) do
					tstring = tstring .. "\n- " .. tags.format(pt, tv)
				end

				item.description = item.description .. tstring
			end
		end
	end

	register(item)
	return default_handler(item)
end
