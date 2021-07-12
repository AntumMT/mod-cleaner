project = "Cleaner"
title = "Cleaner mod for Minetest"
format = "markdown"
boilerplate = false

file = {
	"settings.lua",
	"api.lua",
	"chat.lua",
}

new_type("chatcmd", "Chat Commands")
new_type("setting", "Settings")

custom_tags = {
	{
		"settype",
		title = "Setting Type",
	},
	{
		"default",
		title = "Default Value",
	},
}
