
local old_nodes = {}

-- Populate nodes list from file in world path
local n_list = nil
local n_path = core.get_worldpath() .. "/clean_nodes.txt"
local n_file = io.open(n_path, "r")

if n_file then
	n_list = n_file:read("*a")
	n_file:close()
else
	-- Create empty file
	n_file = io.open(n_path, "w")
	if n_file then
		n_file:close()
	end
end

if n_list then
	cleaner.log("debug", "Loading nodes to clean from file ...")

	n_list = string.split(n_list, "\n")
	for _, node_name in ipairs(n_list) do
		table.insert(old_nodes, node_name)
	end
end

for _, node_name in ipairs(old_nodes) do
	cleaner.log("debug", "Cleaning node: " .. node_name)

	core.register_node(":" .. node_name, {
		groups = {old=1},
	})
end

core.register_abm({
	nodenames = {"group:old"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
			core.remove_node(pos)
	end,
})
