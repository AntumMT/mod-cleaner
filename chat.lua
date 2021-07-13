
--- Cleaner Chat Commands
--
--  @topic commands


local S = core.get_translator(cleaner.modname)


local function pos_list(ppos, radius)
	local plist = {}

	for x = ppos.x - radius, ppos.x + radius, 1 do
		for y = ppos.y - radius, ppos.y + radius, 1 do
			for z = ppos.z - radius, ppos.z + radius, 1 do
				table.insert(plist, {x=x, y=y, z=z})
			end
		end
	end

	return plist
end

local param_desc = {
	["radius"] = S("Search radius."),
	["entity"] = S("Entity technical name."),
	["node"] = S("Node technical name."),
	["old_node"] = S("Technical name of node to be replaced."),
	["new_node"] = S("Technical name of node to be used in place."),
	["old_item"] = S("Technical name of item to be replaced."),
	["new_item"] = S("Technical name of item to be used in place."),
	["ore"] = S("Ore technical name."),
}

local function format_help(cmd, param_string, params)
	local retval = S("Usage:") .. "\n  /" .. cmd .. " " .. param_string
		.. "\n"

	local p_count = 0
	for _, p in ipairs(params) do
		if p_count == 0 then
			retval = retval .. "\n" .. S("Params:")
		end

		retval = retval .. "\n  " .. S(p) .. ": " .. param_desc[p]
		p_count = p_count + 1
	end

	return retval
end

local cmd_repo = {
	entity = {
		cmd = "remove_entity",
		params = "<" .. S("entity") .. "> [" .. S("radius") .. "]",
	},
	node = {
		cmd_rem = "remove_node",
		cmd_rep = "replace_node",
		cmd_find = "find_unknown_nodes",
		params_rem = "<" .. S("node") .. "> [" .. S("radius") .. "]",
		params_rep = "<" .. S("old_node") .. "> <" .. S("new_node") .. "> [" .. S("radius") .. "]",
		params_find = "[" .. S("radius") .. "]",
	},
	item = {
		cmd = "replace_item",
		params = "<" .. S("old_item") .. "> <" .. S("new_item") .. ">",
	},
	ore = {
		cmd = "remove_ore",
		params = "<" .. S("ore") .. ">",
	},
	param = {
		missing = S("Missing parameter."),
		excess = S("Too many parameters."),
		mal_radius = S("Radius must be a number."),
	},
}


--- Removes nearby entities.
--
--  @chatcmd remove_entity
--  @param entity Entity technical name.
--  @tparam[opt] int radius
core.register_chatcommand(cmd_repo.entity.cmd, {
	privs = {server=true},
	description = S("Remove an entity from game."),
	params = cmd_repo.entity.params,
	func = function(name, param)
		local entity
		local radius = 100
		if param:find(" ") then
			entity = param:split(" ")
			radius = tonumber(entity[2])
			entity = entity[1]
		else
			entity = param
		end

		local err
		if not entity or entity:trim() == "" then
			err = cmd_repo.param.missing
		elseif not radius then
			err = cmd_repo.param.mal_radius
		end

		if err then
			return false, err .. "\n\n"
				.. format_help(cmd_repo.entity.cmd, cmd_repo.entity.params, {"entity", "radius"})
		end

		local player = core.get_player_by_name(name)

		local total_removed = 0
		for _, object in ipairs(core.get_objects_inside_radius(player:get_pos(), radius)) do
			local lent = object:get_luaentity()

			if lent then
				if lent.name == entity then
					object:remove()
					total_removed = total_removed + 1
				end
			else
				if object:get_properties().infotext == entity then
					object:remove()
					total_removed = total_removed + 1
				end
			end
		end

		return true, S("Removed @1 entities.", total_removed)
	end,
})

--- Removes nearby nodes.
--
--  @chatcmd remove_node
--  @param node Node technical name.
--  @tparam[opt] int radius
core.register_chatcommand(cmd_repo.node.cmd_rem, {
	privs = {server=true},
	description = S("Remove a node from game."),
	params = cmd_repo.node.params_rem,
	func = function(name, param)
		local nname
		local radius = 100
		if param:find(" ") then
			nname = param:split(" ")
			radius = tonumber(nname[2])
			nname = nname[1]
		else
			nname = param
		end

		local err
		if not nname or nname:trim() == "" then
			err = cmd_repo.param.missing
		elseif not radius then
			err = cmd_repo.param.mal_radius
		end

		if err then
			return false, err .. "\n\n"
				.. format_help(cmd_repo.node.cmd_rem, cmd_repo.node.params_rem, {"node", "radius"})
		end

		local ppos = core.get_player_by_name(name):get_pos()

		local total_removed = 0
		for _, npos in ipairs(pos_list(ppos, radius)) do
			local node = core.get_node_or_nil(npos)
			if node and node.name == nname then
				core.remove_node(npos)
				total_removed = total_removed + 1
			end
		end

		return true, S("Removed @1 nodes.", total_removed)
	end,
})

--- Replaces an item.
--
--  @chatcmd replace_item
--  @param old_item Technical name of item to replace.
--  @param new_item Technical name of item to be used in place.
core.register_chatcommand(cmd_repo.item.cmd, {
	privs = {server=true},
	description = S("Replace an item in game."),
	params = cmd_repo.item.params,
	func = function(name, param)
		local help = format_help(cmd_repo.item.cmd, cmd_repo.item.params, {"old_item", "new_item"})

		if not param:find(" ") then
			return false, cmd_repo.param.missing .. "\n\n" .. help
		end

		local src = param:split(" ")
		local tgt = src[2]
		src = src[1]

		local retval, msg = cleaner.replace_item(src, tgt, true)
		if not retval then
			return false, msg
		end

		return true, S("Success!")
	end,
})

--- Replaces nearby nodes.
--
--  FIXME: sometimes nodes on top disappear
--
--  @chatcmd replace_node
--  @param old_node Technical name of node to replace.
--  @param new_node Technical name of node to be used in place.
--  @tparam[opt] int radius
core.register_chatcommand(cmd_repo.node.cmd_rep, {
	privs = {server=true},
	description = S("Replace a node in game."),
	params = cmd_repo.node.params_rep,
	func = function(name, param)
		local help = format_help(cmd_repo.node.cmd_rep, cmd_repo.node.params_rep, {"old_node", "new_node", "radius"})

		if not param:find(" ") then
			return false, cmd_repo.param.missing .. "\n\n" .. help
		end

		local radius = 100
		local params = param:split(" ")

		local src = params[1]
		local tgt = tostring(params[2])
		if #params > 2 then
			radius = tonumber(params[3])
		end

		if not radius then
			return false, cmd_repo.param.mal_radius .. "\n\n" .. help
		end

		local new_node = core.registered_nodes[tgt]
		if not new_node then
			return false, S('Cannot use unknown node "@1" as replacement.', tgt)
		end

		local total_replaced = 0
		local ppos = core.get_player_by_name(name):get_pos()
		for _, npos in ipairs(pos_list(ppos, radius)) do
			local node = core.get_node_or_nil(npos)
			if node and node.name == src then
				core.remove_node(npos)
				core.place_node(npos, new_node)
				total_replaced = total_replaced + 1
			end
		end

		return true, S("Replaced @1 nodes.", total_replaced)
	end,
})

--- Checks for nearby unknown nodes.
--
--  @chatcmd find_unknown_nodes
--  @tparam[opt] int radius Search radius.
core.register_chatcommand(cmd_repo.node.cmd_find, {
	privs = {server=true},
	description = S("Find names of unknown nodes."),
	params = cmd_repo.node.params_find,
	func = function(name, param)
		local help = format_help(cmd_repo.node.cmd_find, cmd_repo.node.params_find, {"radius"})

		if param:find(" ") then
			return false, cmd_repo.param.excess .. "\n\n" .. help
		end

		local radius = 100
		if param and param:trim() ~= "" then
			radius = tonumber(param)
		end

		if not radius then
			return false, cmd_repo.param.mal_radius .. "\n\n" .. help
		end

		local ppos = core.get_player_by_name(name):get_pos()

		local checked_nodes = {}
		local unknown_nodes = {}
		for _, npos in ipairs(pos_list(ppos, radius)) do
			local node = core.get_node_or_nil(npos)
			if node and not checked_nodes[node.name] then
				if not core.registered_nodes[node.name] then
					table.insert(unknown_nodes, node.name)
				end

				checked_nodes[node.name] = true
			end
		end

		local msg
		if #unknown_nodes > 0 then
			msg = S("Found unknown nodes: @1", table.concat(unknown_nodes, ", "))
		else
			msg = S("No unknown nodes found.")
		end

		return true, msg
	end,
})


--- Unsafe commands.
--
--  Enabled with `cleaner.unsafe` setting.
--
--  @section unsafe


if cleaner.unsafe then
	--- Registers an ore to be removed.
	--
	--  @chatcmd remove_ore
	--  @param ore Ore technical name.
	core.register_chatcommand(cmd_repo.ore.cmd, {
		privs = {server=true},
		description = S("Remove an ore from game."),
		params = cmd_repo.ore.params,
		func = function(name, param)
			local err
			if not param or param:trim() == "" then
				err = cmd_repo.param.missing
			elseif param:find(" ") then
				err = cmd_repo.param.excess
			end

			if err then
				return false, err .. "\n\n" .. format_help(cmd_repo.ore.cmd, cmd_repo.ore.params, {"ore"})
			end

			local success = false
			local msg
			local registered, total_removed = cleaner.remove_ore(param)

			if not registered then
				msg = S('Ore "@1" not found, not unregistering.', param)
			else
				msg = S("Unregistered @1 ores (this will be undone after server restart).", total_removed)
				success = true
			end

			return success, msg
		end
	})
end
