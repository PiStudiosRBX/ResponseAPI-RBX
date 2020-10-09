local COMMAND_PARSER = require(script.Parent.Parent.Modules.CommandParser)
local util = {}
local wildcardFunctions = {}
local Response
util.__index = util
-----------------------------------------------------
local function domify(t, k)
	if not k then
		return t
	end
	
	local out = {}
	for i, v in pairs(t) do
		out[i] = v[k]
	end
	return out
end
-----------------------------------------------------
wildcardFunctions["@a"] = function(t)
	return t
end

wildcardFunctions["@r"] = function(t)
	return {t[math.random(1, #t)]}
end
-----------------------------------------------------
function util:AppendTable(t1, t2) --appends t2 to t1
	for _, v in pairs(t2) do
		t1[#t1 + 1] = v
	end
end

function util:ParseCommand(text)
    return COMMAND_PARSER(text)
end

function util:ShorternTable(tab, shorternLength) --shorterns an array and makes it's keys the new length
	local out = {}
	for k, v in pairs(tab) do
		if type(k) == "string" then
			out[k:sub(1, shorternLength):lower()] = v
		end
	end
	return out	
end

function util:Wildcard(argumentTable, targetTable, dominantKey) --apply wildcards
	for i, v in pairs(argumentTable) do
		if wildcardFunctions[v] then
			table.remove(argumentTable, i)
			self:AppendTable(argumentTable, domify(wildcardFunctions[v](targetTable), dominantKey))
		end
	end
end

function util:ProcessArguments(arguments, hashmap, dominantKey, callback) --custom table.foreach comparison, parse arguments to check. Runs the function if the value is in the arguments table
	--wrap table
	self:Wildcard(arguments, hashmap, dominantKey)
	
	local wrappedTable = {}
	for _, v in pairs(hashmap) do
		wrappedTable[v[dominantKey] or v] = v
	end
	
	for _, v in pairs(arguments) do
		local shorterned = self:ShorternTable(wrappedTable, v:len())
		if shorterned[v:lower()] then
			callback(shorterned[v:lower()])
		end
	end
end

return function(Response)
	Response = Response
	return util
end

