
local tags = {}
local tag_list = {}
local custom_tags = {}

local register_tag = function(name, tag)
	local new_tag = {name, title=tag.title, hidden=tag.hidden, format=tag.format}
	table.insert(custom_tags, new_tag)
	tag_list[name] = {title=tag.title, format=tag.format}
end

tags.get_title = function(tname)
	local t = tag_list[tname]
	if t then
		return t.title
	end
end

tags.format = function(tname, value)
	local t = tag_list[tname]
	if t then
		if type(t.format) == "function" then
			value = t.format(value)
		end
	end

	return value
end


local new_tags = {
	["priv"] = {
		title = "Required Privileges",
		hidden = true,
	},
	["note"] = {
		title = "Notes",
		hidden = true,
		format = function(value)
			return "*" .. value .. "*"
		end,
	},
	["video"] = {
		title = "Video",
		format = video_frame,
	},
	["youtube"] = {
		title = "Video",
		format = function(value)
			return video_frame("https://www.youtube.com/embed/" .. value)
		end,
	},
	-- settings
	["settype"] = {
		title = "Setting Type",
		hidden = true,
	},
	["default"] = {
		title = "Default Value",
		hidden = true,
	},
	-- craft items/tools
	["img"] = {
		title = "Image",
		format = function(value)
			return "<img src=\"../data/" .. value .. "\" style=\"width:32px; height:32px;\" />"
		end,
	},
	-- chat commands
	["chatparam"] = {
		title = "Parameters",
		hidden = true,
	},
}

for k, v in pairs(new_tags) do
	register_tag(k, v)
end


return tags, custom_tags
