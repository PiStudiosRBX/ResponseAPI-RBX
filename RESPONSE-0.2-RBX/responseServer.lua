--// Response 0.2
--// FilteredDev

--// Chat Runner, OP initialiser and Event binder for Response API
local ResponseEnvironment = script.Parent
local PREFIX = "$"
local ChatService = require(game:GetService("ServerScriptService"):WaitForChild("ChatServiceRunner").ChatService)
local Players = game:GetService("Players")
local RESPONSE_API = require(ResponseEnvironment.ResponseAPI.Response)

local OUTPUT_POINTERS = {
	Output = Color3.new(1,1,1),
	Warning = Color3.fromRGB(255,170,0),
	Error = Color3.fromRGB(255,89,89)
}

RESPONSE_API.OutputCallback = function(text, output, metadata)
	if metadata.SpeakerName then
		local SPEAKER = ChatService:GetSpeaker(metadata.SpeakerName)
		SPEAKER:SendSystemMessage(text, metadata.ChannelName, {ChatColor = OUTPUT_POINTERS[output]})
	end
end

local function ResponseChatHandler(speakerName, content, channelName)
	local APPENDED_DATA = {
		SpeakerName = speakerName,
		ChannelName = channelName,
		ChatService = ChatService
	}
	
	if content:sub(1,1) == PREFIX then
		--assumes we're parsing a Response command
		RESPONSE_API:ProcessCommand(content:sub(2), APPENDED_DATA)
		return true
	end
	
	return false
end

ChatService:RegisterProcessCommandsFunction("ResponseCommandProcessor", ResponseChatHandler)

--Invokers
Players.PlayerAdded:Connect(function(p)
	RESPONSE_API.Permissions:Setup(p)
	RESPONSE_API.PluginManager.InvokePlayerAdded(p)
end)
Players.PlayerRemoving:Connect(RESPONSE_API.PluginManager.InvokePlayerRemoving)

--Start Plugins
for _, v in pairs(ResponseEnvironment.Plugins:GetChildren()) do
	RESPONSE_API.PluginManager:RegisterPlugin(require(v))
end

RESPONSE_API.ChatService = ChatService --this is a bit hacky, but hey it does the job i guess
RESPONSE_API.PluginManager:StartAllPlugins()
RESPONSE_API.PluginManager:QuickRun(require(ResponseEnvironment.Base.DCOMM_RBX))
print("ResponseRBX.2 Running!")