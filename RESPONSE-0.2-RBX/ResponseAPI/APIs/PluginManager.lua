local pluginMan = {Plugins = {}}
local Response
pluginMan.__index = pluginMan

--Modified for Roblox (PlayerAdded and PlayerRemoved callback invokers)

function pluginMan:RegisterPlugin(pluginMetadata)
    self.Plugins[pluginMetadata.Name] = pluginMetadata
    pluginMetadata.Initialize(Response)
end

function pluginMan:QuickRun(pluginMetadata)
    pluginMetadata.Initialize(Response)
    pluginMetadata.Start(Response)
end

function pluginMan:UnregisterPlugin(name)
    local plugin = assert(self.Plugins[name], "This plugin is not registered")
    plugin.Stop()
    self.Plugins[name] = nil
end

function pluginMan:StartAllPlugins()
    for _, v in pairs(self.Plugins) do
        v.Start()
    end
end

function pluginMan:InvokePlayerAdded(p)
	for _, v in pairs(self.Plugins) do
		if v.PlayerAdded then
			v.PlayerAdded(p)
		end
	end
end

function pluginMan:InvokePlayerRemoving(p)
	for _, v in pairs(self.Plugins) do
		if v.PlayerRemoving then
			v.PlayerRemoving(p)
		end
	end
end

----------------------------------------------------------------
local Interface = {}

return function(api)
    Response = api
    local o = setmetatable({}, pluginMan)
    o.Plugins = {}

    return o
end