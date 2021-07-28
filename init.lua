
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
	on_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end

		local pname = user:get_player_name()
		if not core.get_player_privs(pname).server then
			core.chat_send_player(pname, S("You do not have permission to use this item. Missing privs: server"))
			return itemstack
		end

		if sound_handle then
			core.sound_stop(sound_handle)
			sound_handle = nil
		end

		if pointed_thing.type == "node" then
			local npos = core.get_pointed_thing_position(pointed_thing)
			local imeta = itemstack:get_meta()
			local mode = imeta:get_string("mode")
			local new_node_name = imeta:get_string("node")

			if mode == "erase" then
				core.remove_node(npos)
				sound_handle = core.sound_play("cleaner_pencil_erase", {object=user})
				return itemstack
			elseif core.registered_nodes[new_node_name] then
				if mode == "swap" then
					core.swap_node(npos, {name=new_node_name})
					sound_handle = core.sound_play("cleaner_pencil_write", {object=user})
					return itemstack
				elseif mode == "write" then
					local node_above = core.get_node_or_nil(pointed_thing.above)
					if not node_above or node_above.name == "air" then
						core.place_node(pointed_thing.above, {name=new_node_name})
						sound_handle = core.sound_play("cleaner_pencil_write", {object=user})
					else
						core.chat_send_player(pname, S("Can't place node there."))
					end

					return itemstack
				else
					core.chat_send_player(pname, S("Unknown mode: @1", mode))
				end
			end

			core.chat_send_player(pname, S("Cannot place unknown node: @1", new_node_name))
			return itemstack
		end
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end

		local pname = user:get_player_name()
		if not core.get_player_privs(pname).server then
			core.chat_send_player(pname, S("You do not have permission to use this item. Missing privs: @1", "server"))
			return itemstack
		end

		local imeta = itemstack:get_meta()
		local mode = imeta:get_string("mode")
		if mode == "erase" or mode == "" then
			mode = "write"
		elseif mode == "write" then
			mode = "swap"
		else
			mode = "erase"
		end

		return aux.tool:set_mode(itemstack, mode, pname)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if not placer:is_player() then return end

		local pname = placer:get_player_name()
		if not core.get_player_privs(pname).server then
			core.chat_send_player(pname, S("You do not have permission to use this item. Missing privs: @1", "server"))
			return itemstack
		end

		if pointed_thing.type == "node" then
			local node = core.get_node_or_nil(core.get_pointed_thing_position(pointed_thing))
			if node then
				itemstack = aux.tool:set_node(itemstack, node.name, pname)
			end
		end

		return itemstack
	end,
})
