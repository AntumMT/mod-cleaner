
local misc = dofile(cleaner.modpath .. "/misc_functions.lua")

-- populate entities list from file in world path
local e_list = {remove={}}
local e_path = core.get_worldpath() .. "/clean_entities.json"
local e_file = io.open(e_path, "r")

if e_file then
	local data_in = core.parse_json(e_file:read("*a"))
	e_file:close()
	if data_in then
		e_list = data_in
	end
end

-- backward compat
local e_path_old = core.get_worldpath() .. "/clean_entities.txt"
e_file = io.open(e_path_old, "r")

if e_file then
	cleaner.log("action", "found deprecated clean_entities.txt, converting to json")

	local data_in = string.split(e_file:read("*a"), "\n")
	for _, e in ipairs(data_in) do
		e = e:trim()
		if e ~= "" and e:sub(1, 1) ~= "#" then
			table.insert(e_list.remove, e)
		end
	end

	e_file:close()
	os.rename(e_path_old, e_path_old .. ".bak") -- don't read deprecated file again
end

e_list.remove = misc.clean_duplicates(e_list.remove)

-- update json file with any changes
e_file = io.open(e_path, "w")
if e_file then
	local data_out = core.write_json(e_list, true):gsub("\"remove\" : null", "\"remove\" : []")
	e_file:write(data_out)
	e_file:close()
end


for _, e in ipairs(e_list.remove) do
	cleaner.log("debug", "Cleaning entity: " .. e)

	core.register_entity(":" .. e, {
		on_activate = function(self, staticdata)
			self.object:remove()
		end,
	})
end
