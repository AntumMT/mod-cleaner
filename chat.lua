
--- Cleaner Chat Commands
--
--  @topic commands


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


--- Removes nearby entities.
--
--  @chatcmd remove_entity
--  @param entity Entity technical name.
core.register_chatcommand("remove_entity", {
	privs = {server=true},
	description = "Remove an entity from game.",
	params = "<entity> [radius]",
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

		if not entity or entity:trim() == "" then
			return false, "Must supply entity name."
		elseif not radius then
			return false, "Radius must be a number."
		end

		local player = core.get_player_by_name(name)

		for _, object in ipairs(core.get_objects_inside_radius(player:get_pos(), radius)) do
			local lent = object:get_luaentity()

			if lent then
				if lent.name == entity then
					object:remove()
				end
			else
				if object:get_properties().infotext == entity then
					object:remove()
				end
			end
		end

		return true
	end,
})

--- Removes nearby nodes.
--
--  @chatcmd remove_node
--  @param node Node technical name.
core.register_chatcommand("remove_node", {
	privs = {server=true},
	description = "Remove a node from game.",
	params = "<node> [radius]",
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

		if not nname or nname:trim() == "" then
			return false, "Must supply node name."
		elseif not radius then
			return false, "Radius must be a number."
		end

		local ppos = core.get_player_by_name(name):get_pos()

		for _, npos in ipairs(pos_list(ppos, radius)) do
			local node = core.get_node_or_nil(npos)
			if node and node.name == nname then
				core.remove_node(npos)
			end
		end

		return true
	end,
})

local function replace_item(src, tgt)
	if not core.registered_items[tgt] then
		return false, "Cannot use unknown item \"" .. tgt .. "\" as replacement."
	end

	if core.registered_items[src] then
		core.unregister_item(src)
	end

	core.register_alias(src, tgt)
	return true
end

--- Replaces an item.
--
--  FIXME: inventory icons not updated
--
--  @chatcmd replace_item
--  @param old_item Technical name of item to replace.
--  @param new_item Technical name of item to be used in place.
core.register_chatcommand("replace_item", {
	privs = {server=true},
	description = "Replace an item in game.",
	params = "<old_item> <new_item>",
	func = function(name, param)
		if not param:find(" ") then
			return false, "Not enough parameters."
		end

		local src = param:split(" ")
		local tgt = src[2]
		src = src[1]

		local retval, msg = replace_item(src, tgt)
		if not retval then
			return false, msg
		end

		return true
	end,
})

--- Replaces nearby nodes.
--
--  @chatcmd replace_item
--  @param old_node Technical name of node to replace.
--  @param new_node Technical name of node to be used in place.
core.register_chatcommand("replace_node", {
	privs = {server=true},
	description = "Replace a node in game.",
	params = "<old_node> <new_node> [radius]",
	func = function(name, param)
		if not param:find(" ") then
			return false, "Not enough parameters."
		end

		local radius = 100
		local params = param:split(" ")

		local src = params[1]
		local tgt = tostring(params[2])
		if #params > 2 then
			radius = tonumber(params[3])
		end

		if not radius then
			return false, "Radius must be a number."
		end

		local new_node = core.registered_nodes[tgt]
		if not new_node then
			return false, "Cannot use unknown node \"" .. tgt .. "\" as replacement."
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

		core.chat_send_player(name, "Replaced " .. total_replaced .. " nodes.")
		return true
	end,
})

--- Checks for nearby unknown nodes.
--
--  @chatcmd find_unknown_nodes
--  @tparam[opt] int radius Search radius.
core.register_chatcommand("find_unknown_nodes", {
	privs = {server=true},
	description = "Find names of unknown nodes.",
	params = "[radius]",
	func = function(name, param)
		if param:find(" ") then
			return false, "Too many parameters."
		end

		local radius = 100
		if param and param:trim() ~= "" then
			radius = tonumber(param)
		end

		if not radius then
			return false, "Radius must be a number."
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

		if #unknown_nodes > 0 then
			core.chat_send_player(name, "Found unknown nodes: " .. table.concat(unknown_nodes, ", "))
		else
			core.chat_send_player(name, "No unknown nodes found")
		end

		return true
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
	core.register_chatcommand("remove_ore", {
		privs = {server=true},
		description = "Remove an ore from game.",
		params = "<ore>",
		func = function(name, param)
			if param:find(" ") then
				return false, "Too many parameters."
			end

			core.after(0, function()
				local registered, total_removed = cleaner.remove_ore(param)

				if not registered then
					core.chat_send_player(name, "Ore \"" .. param .. "\" not found, not unregistering.")
				else
					core.chat_send_player(name, "Unregistered " .. total_removed .. " ores (this will be undone after server restart).")
				end
			end)

			return true
		end
	})
end
