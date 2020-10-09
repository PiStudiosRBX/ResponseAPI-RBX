--//Default Commands
--//Response API 2
--//FilteredDev

local DCOMM_PLUGIN = {}
DCOMM_PLUGIN.CommandList = {}

local Response
local Players = game:GetService("Players")
--local HelpUtil = require("./help_util") --relic from the vanilla version, will probs fix in the near future

DCOMM_PLUGIN.Name = "DCOMM"

DCOMM_PLUGIN.HelpMetadata = {
    DisplayName = "Default Command List",
    Description = "Holds the default commands used by Response"
}

DCOMM_PLUGIN.CommandList.Test = {
    Name = "test",
    HelpMetadata = {
        Description = "Tests the API to make sure it correctly handles incoming arguments",
        Arguments = "test ..."
	},

    Command = function(metadata)
        print("Name", metadata.Command)
        print("Username", metadata.Username or "???")

        for _, v in ipairs(metadata.BlankArguments) do
            print(v)
        end

        for k, v in pairs(metadata.Arguments) do
            print(k, v)
        end

        return true
    end
}

--[[
DCOMM_PLUGIN.CommandList.Kill = {
	Name = "kill",
	HelpMetadata = {},
	
	Command = function(metadata)
		if #metadata.BlankArguments == 0 then
			local v = Players:FindFirstChild(metadata.SpeakerName)
			if v and v.Character then
				v.Character.Humanoid.Health = 0
			end
			return true
		end
		
		local targets = Players:GetPlayers()
		Response.util:ProcessArguments(metadata.BlankArguments, targets, "Name", function(target)
			if target.Character then
				target.Character.Humanoid.Health = 0
			end
		end)
		
		return true
	end
}]]-- kept for reference, will move to the right area soon

DCOMM_PLUGIN.CommandList.GetVersion = {
	Name = "version",
	HelpMetadata = {},
	
	Command = function(metadata)
		Response:InvokeErrorCallback("Response v" .. Response.Settings.Version, "Output", metadata)
		return true
	end
}

function DCOMM_PLUGIN.Initialize(api)
    Response = api
    --HelpUtil.Response = api

    return true
end

function DCOMM_PLUGIN.Start()
    Response.CommandManager:BulkRegister(DCOMM_PLUGIN.CommandList)

    return true
end

function DCOMM_PLUGIN.Stop()
    Response.CommandManager:BulkUnregister(DCOMM_PLUGIN.CommandList)

    return true
end

return DCOMM_PLUGIN