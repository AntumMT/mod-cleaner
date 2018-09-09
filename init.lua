--[[ Cleaner mod
     License: CC0
]]


cleaner = {}
cleaner.name = core.get_current_modname()

local debug = core.settings:get_bool('enable_debug_mods')

local function log(level, msg)
	core.log(level, '[' .. cleaner.name .. '] ' .. msg)
end

local function logDebug(msg)
	if debug then
		core.log('DEBUG: [' .. cleaner.name .. '] ' .. msg)
	end
end


-- ENTITIES

local old_entities = {}

-- Populate entities list from file in world path
local e_list = nil
local e_path = core.get_worldpath() .. '/clean_entities.txt'
local e_file = io.open(e_path, 'r')
if e_file then
	e_list = e_file:read('*a')
	e_file:close()
else
	-- Create empty file
	e_file = io.open(e_path, 'w')
	if e_file then
		e_file:close()
	end
end

if e_list then
	logDebug('Loading entities to clean from file ...')
	
	e_list = string.split(e_list, '\n')
	for _, entity_name in ipairs(e_list) do
		table.insert(old_entities, entity_name)
	end
end

for _, entity_name in ipairs(old_entities) do
	logDebug('Cleaning entity: ' .. entity_name)
	
    core.register_entity(':' .. entity_name, {
        on_activate = function(self, staticdata)
            self.object:remove()
        end,
    })
end


-- NODES

local old_nodes = {}

-- Populate nodes list from file in world path
local n_list = nil
local n_path = core.get_worldpath() .. '/clean_nodes.txt'
local n_file = io.open(n_path, 'r')
if n_file then
	n_list = n_file:read('*a')
	n_file:close()
else
	-- Create empty file
	n_file = io.open(n_path, 'w')
	if n_file then
		n_file:close()
	end
end


if n_list then
	logDebug('Loading nodes to clean from file ...')
	
	n_list = string.split(n_list, '\n')
	for _, node_name in ipairs(n_list) do
		table.insert(old_nodes, node_name)
	end
end

for _, node_name in ipairs(old_nodes) do
	logDebug('Cleaning node: ' .. node_name)
	
    core.register_node(':' .. node_name, {
        groups = {old=1},
    })
end


local replace_nodes = {}


local n_list = nil
local n_path = core.get_worldpath() .. '/replace_nodes.txt'
local n_file = io.open(n_path, 'r')
if n_file then
	n_list = n_file:read('*a')
	n_file:close()
else
	-- Create empty file
	n_file = io.open(n_path, 'w')
	if n_file then
		n_file:close()
	end
end

if n_list then
	logDebug('Loading nodes to replace from file ...')
	
	n_list = string.split(n_list, '\n')
	for _, node_def in ipairs(n_list) do
                node_list = string.split(node_def, '->')
		replace_nodes[node_list[1]] = node_list[2]
	end
end

for old_node, new_node in pairs(replace_nodes) do
	logDebug('Replacing node ' .. old_node .. ' with ' .. new_node)
	
    core.register_node(':' .. old_node, {
        groups = {old_replaced=1},
    })
end

core.register_lbm({
    name = "cleaner:remove_old_nodes",
    nodenames = {'group:old'},
    run_at_every_load = true,
    action = function(pos, node)
        logDebug('Replacing?')
        core.remove_node(pos)
    end,
})

core.register_lbm({
    name = "cleaner:replace_old_nodes",
    nodenames = {'group:old_replaced'},
    run_at_every_load = true,
    action = function(pos, node)
        core.set_node(pos, {name = replace_nodes[node.name]})
    end,
})
