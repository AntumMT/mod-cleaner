project = "Cleaner"
title = "Cleaner mod for Minetest"
format = "markdown"
boilerplate = false
style = true

file = {
	"init.lua",
	"settings.lua",
	"api.lua",
	"chat.lua",
}

new_type("chatcmd", "Chat Commands")
new_type("setting", "Settings")
new_type("tool", "Tools")

custom_tags = {
	{
		"privs",
		title = "Required Privileges",
	},
	-- settings
	{
		"settype",
		title = "Setting Type",
	},
	{
		"default",
		title = "Default Value",
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
