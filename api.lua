
--- Cleaner API
--
--  @topic api


local replace_items = {}
local replace_nodes = {}


--- Retrieves list of items to be replaced.
--
--  @treturn table Items to be replaced.
function cleaner.get_replace_items()
	return replace_items
end

--- Retrieves list of nodes to be replaced.
--
--  @treturn table Nodes to be replaced.
function cleaner.get_replace_nodes()
	return replace_nodes
end


--- Registers an entity to be removed.
--
--  @tparam string src Entity technical name.
function cleaner.register_entity_removal(src)
	core.register_entity(":" .. src, {
		on_activate = function(self, ...)
			self.object:remove()
		end,
	})
end

--- Registers a node to be removed.
--
--  @tparam string src Node technical name.
function cleaner.register_node_removal(src)
	core.register_node(":" .. src, {
		groups = {to_remove=1},
	})
end

--- Registeres an item to be replaced.
--
--  @tparam string src Technical name of item to be replaced.
--  @tparam string tgt Technical name of item to be used in place.
function cleaner.register_item_replacement(src, tgt)
	replace_items[src] = tgt
end

--- Registers a node to be replaced.
--
--  @tparam string src Technical name of node to be replaced.
--  @tparam string tgt Technical name of node to be used in place.
function cleaner.register_node_replacement(src, tgt)
	core.register_node(":" .. src, {
		groups = {to_replace=1},
	})

	replace_nodes[src] = tgt
end


--- Unsafe methods.
--
--  Enabled with `cleaner.unsafe` setting.
--
--  @section unsafe


if cleaner.unsafe then
	local remove_ores = {}

	--- Retrieves list of ores to be removed.
	--
	--  @treturn table Ores to be replaced.
	function cleaner.get_remove_ores()
		return remove_ores
	end

	--- Registers an ore to be removed after server startup.
	--
	--  @tparam string src Ore technical name.
	function cleaner.register_ore_removal(src)
		table.insert(remove_ores, src)
	end

	--- Removes an ore definition.
	--
	--  @tparam string src Ore technical name.
	function cleaner.remove_ore(src)
		local remove_ids = {}
		local total_removed = 0
		local registered = false

		for id, def in pairs(core.registered_ores) do
			if def.ore == src then
				table.insert(remove_ids, id)
				registered = true
			end
		end

		for _, id in ipairs(remove_ids) do
			core.registered_ores[id] = nil
			if core.registered_ores[id] then
				cleaner.log("error", "unable to unregister ore " .. id)
			else
				total_removed = total_removed + 1
			end
		end

		return registered, total_removed
	end
end
