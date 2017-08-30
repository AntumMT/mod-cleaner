--[[ Clean mod
     License: CC0
]]


clean = {}
clean.name = core.get_current_modname()

local debug = core.settings:get_bool('enable_debug_mods')

local function log(level, msg)
	core.log(level, '[' .. clean.name .. '] ' .. msg)
end

local function logDebug(msg)
	if debug then
		core.log('DEBUG: [' .. clean.name .. '] ' .. msg)
	end
end

local old_nodes = {}
local old_entities = {}

-- Old/Missing nodes that should be replaced with something currently in game
local replace_nodes = {}


-- "Replaces" an old/non-existent node
local function replace_node(old_node, new_node)
    core.register_alias(old_node, new_node)
end


for _,node_name in ipairs(old_nodes) do
    core.register_node(':' .. node_name, {
        groups = {old=1},
    })
end

core.register_abm({
    nodenames = {'group:old'},
    interval = 1,
    chance = 1,
    action = function(pos, node)
        core.remove_node(pos)
    end,
})

for _, entity_name in ipairs(old_entities) do
    core.register_entity(':' .. entity_name, {
        on_activate = function(self, staticdata)
            self.object:remove()
        end,
    })
end

-- Replace old nodes
for _, node_group in pairs(replace_nodes) do
    replace_node(node_group[1], node_group[2])
end
