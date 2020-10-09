--//Response API and APISection loader
--//FilteredDev
--//Mildly modified for Roblox's helpful child API

local Response = {}
Response.__index = Response

--Packagae API
Response.Settings = require(script.Parent.Settings)(Response)
for _, v in pairs(script.Parent.APIs:GetChildren()) do
	Response[v.Name] = require(v)(Response)
end

--Response Object
function Response:InvokeErrorCallback(text, outType, metadata)
    if self.OutputCallback then
        self.OutputCallback(text, outType, metadata)
    end
end

function Response:ProcessCommand(text, commandDataAppend)
	local s, e = pcall(function()
	    local command = self.util:ParseCommand(text)
	    for key, value in pairs(commandDataAppend) do
	        if not command[key] then
	            command[key] = value
	        end
	    end
		
		self.CommandManager:RunCommand(command.Command, command)
	end)
	if not s then
		self:InvokeErrorCallback("Error while processing command: " .. (e or "No output from Response"), "Output", commandDataAppend)
	end
end

return Response