
local replace_items = {}
local replace_nodes = {}


function cleaner.get_replace_items()
	return replace_items
end

function cleaner.get_replace_nodes()
	return replace_nodes
end


function cleaner.remove_entity(src)
	core.register_entity(":" .. src, {
		on_activate = function(self, staticdata)
			self.object:remove()
		end,
	})
end

function cleaner.remove_node(src)
	core.register_node(":" .. src, {
		groups = {to_remove=1},
	})
end

function cleaner.replace_item(src, tgt)
	replace_items[src] = tgt
end

function cleaner.replace_node(src, tgt)
	core.register_node(":" .. src, {
		groups = {to_replace=1},
	})

	replace_nodes[src] = tgt
end
