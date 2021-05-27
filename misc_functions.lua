
--- Cleans duplicate entries from indexed table.
--
--  @local
--  @function clean_duplicates
--  @tparam table t
--  @treturn table
local function clean_duplicates(t)
	local tmp = {}
	for _, v in ipairs(t) do
		tmp[v] = true
	end

	t = {}
	for k in pairs(tmp) do
		table.insert(t, k)
	end

	return t
end


return {
	clean_duplicates = clean_duplicates,
}
