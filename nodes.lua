
local misc = dofile(cleaner.modpath .. "/misc_functions.lua")

-- populate nodes list from file in world path
local n_list = {remove={}}
local n_path = core.get_worldpath() .. "/clean_nodes.json"
local n_file = io.open(n_path, "r")

if n_file then
	local data_in = core.parse_json(n_file:read("*a"))
	n_file:close()
	if data_in then
		for _, n in ipairs(data_in.remove) do
			table.insert(n_list.remove, n)
		end
	end
end

-- backward compat
local n_path_old = core.get_worldpath() .. "/clean_nodes.txt"
n_file = io.open(n_path_old, "r")

if n_file then
	cleaner.log("action", "found deprecated clean_nodes.txt, converting to json")

	local data_in = string.split(n_file:read("*a"), "\n")
	for _, e in ipairs(data_in) do
		e = e:trim()
		if e ~= "" and e:sub(1, 1) ~= "#" then
			table.insert(n_list.remove, e)
		end
	end

	n_file:close()
	os.rename(n_path_old, n_path_old .. ".bak") -- don't read deprecated file again
end

n_list.remove = misc.clean_duplicates(n_list.remove)

-- update json file with any changes
n_file = io.open(n_path, "w")
if n_file then
	local data_out = core.write_json(n_list, true):gsub("\"remove\" : null", "\"remove\" : []")
	n_file:write(data_out)
	n_file:close()
end

for _, n in ipairs(n_list.remove) do
	cleaner.log("debug", "Cleaning node: " .. n)

	core.register_node(":" .. n, {
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
