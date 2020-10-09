local ESCAPE_CHARACTER = "\\"
local OPERATORS = {
	["{"] = "}", 
	["["] = "]"
}
local OPERATOR_ESCAPES = {
	["}"] = "{",
	["]"] = "["
}

local function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function destring(s)
	if s:sub(1,1) == "\"" then
		s = s:sub(2)
	end
	
	if s:sub(#s) == "\"" then
		s = s:sub(1, #s - 1)
	end
	
	return s
end

local function parse(str, splitChar)
	local unclosedOperators = {}
	local inString
	local output = {}
	local workingString = ""
	
	for i = 1, #str do
		local c = str:sub(i,i)
		
		if str:sub(i-1,i-1) ~= "\\" then
			if c == "\"" then
				if inString then
					inString = nil
				else
					inString = i
				end
			elseif not inString then
				--time for some operator parsing
				if OPERATORS[c] then
					unclosedOperators[#unclosedOperators + 1] = {c, i}
				elseif OPERATOR_ESCAPES[c] then
					if unclosedOperators[#unclosedOperators][1] == OPERATOR_ESCAPES[c] then
						unclosedOperators[#unclosedOperators] = nil
					else
						error(string.format("Invalid Escape at column %s. Expected '%s' to open '%s'", i, OPERATOR_ESCAPES[c], c))
					end
				elseif c == splitChar and #unclosedOperators == 0 then
					output[#output + 1] = workingString
					workingString = ""
					continue
				end
			end
		end
		
		if i == #str then
			local append = (c ~= splitChar and c) or ""
			workingString = workingString .. append
			output[#output + 1] = workingString
		end
		workingString = workingString .. c
		
	end
	
	if inString then
		error("Unclosed String at column " .. inString)
	elseif #unclosedOperators > 0 then
		local m = unclosedOperators[#unclosedOperators]
		print(m[1], m[2])
		error(string.format("Unclosed operator at column %s. Expected '%s' to close '%s'", m[2], OPERATORS[m[1]], m[1]))
	end
	
	return output
end

local function tokenise(str)
	local eqPos = string.find(str, "=")
	if not eqPos then
		return nil, trim(str)
	else
		local argName = destring(trim(str:sub(1, eqPos - 1))):lower()
		local argData = destring(trim(str:sub(eqPos + 1)))
		
		return argName, argData
	end
end

---------------------------------------------------------------
return function(str)
    local str = trim(str)
    
    local findSpace = str:find(" ")
    if not findSpace then
        return {
            Command = str,
            BlankArguments = {},
            Arguments = {}
        }
    end
    
	local command = {
		Command = str:sub(1, findSpace - 1),
		BlankArguments = {},
		Arguments = {}
	}
	
	local o = parse(str:sub(findSpace + 1), ",")
	
	for _, v in pairs(o) do
		local name, data = tokenise(v)
		if not name then
			command.BlankArguments[#command.BlankArguments + 1] = data
		else
			command.Arguments[name] = data
		end
	end
	
	return command
end