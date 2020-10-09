--Response: CommandManager API
local Response
local multipleProxyObject = newproxy(false) --object to specify that this command is registered by multiple objects

----------------------------------------------------------------------------------------------------------------
local _methods = {}
_methods.__index = _methods

function _methods:RegisterComand(n, f, src)
	assert(not self.Commands[n], "Command is already registered, use a new name for this command")
	self.Commands[n] = f
end

function _methods:UnregisterCommand(n, src)
	assert(self.Commands[n], "Command not registered")
	self.Commands[n] = nil
end

function _methods:IsCommandRegistered(n, src)
	return (self.Commands[n] ~= nil)
end

function _methods:RunCommand(n, m)
	local command=self.Commands[n]
	if not command then
		Response:InvokeErrorCallback("Command " .. n .. " is not registered.", "Error", m)
		return
	end

	local pcallS, commandS, e = pcall(command, m)
	
	if not pcallS then
		Response:InvokeErrorCallback("Command experienced an error: " .. commandS, "Error", m)
	elseif not commandS then
		Response:InvokeErrorCallback("Command experienced an error: " .. (e or "No output from command"), "Error", m)	
	end
end

function _methods:BulkRegister(commands)
    for _, COMMAND in pairs(commands) do
        self:RegisterComand(COMMAND.Name, COMMAND.Command)
    end
end

function _methods:BulkUnregister(commandNames)
    --removes by name
    for _, v in ipairs(commandNames) do
        self:UnregisterCommand(v)
    end
end
----------------------------------------------------------------------------------------------------------------
return function(api)
	Response = api
	local o = setmetatable({}, _methods)
	o.Commands = {}
	
	return o
end