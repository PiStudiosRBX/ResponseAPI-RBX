# ResponseAPI-RBX
RBX version of Response API. This module in its current state is VERY barebones

# How Response handles commands.
(wip)

# API
To start using the Response APIs, require the ResponseAPI module script located in ``/ResponseAPI/Response/``
You can then use the various API functions provided by it's API and ModuleScripts in the ``/ResponseAPI/Response/APIs`` folder
API List:
* Response (Base API)
* CommandManager
* PluginManager
* util

Adding your own APIs can be read further down.

# Response

### Properties
|``function`` OutputCallback|
|---|
|States a callback that should be invoked when Response wants to output data. This function is predefined by the loader but it can be overtaken as follows:|
```lua
local Response = require(script.Parent.ResponseAPI.Response)

function Response.outputCallback(text, outputType, metadata)
  print(text, outputType, metadata)
end
```
...where text is the output text attempting to be displayed, outputType is the type of output and metadata is metadata of the command that was processed.

Because this is a callback, please only declare this once for intended behaviour.

### Functions

|``void`` InvokeCallback(``string`` text, ``string`` outputType, ``dictionary`` metadata)|
|---|
|Invokes the OutputCallback.|

|~~``void`` InvokeErrorCallback(``string`` text, ``string`` outputType, ``dictionary`` metadata)~~|
|---|
|Equivelent to InvokeCallback and so is deprecated.|

|``void`` ProcessCommand(``string`` command, ``dictionary`` extraData)|
|---|
|Begins handling a command using the raw command text, this runs it through the command parser, attaches the extra data, then runs the command.|

# Command Manager

### Properties
|``dictionary`` Commands|
|---|
|Reference to all installed commands.|

### Functions

|``void`` BulkRegister(``dictionary`` commands)|
|---|
|Registers multiple commands against CommandManager:RegisterCommand()|

|``void`` BulkUnregister(``array`` commnandNames)|
|---|
|Unregisters multiple commands against CommandManager:UnregisterCommand() using the name as the pairing|

|``bool`` IsCommandRegistered(``string`` commandName)|
|---|
|Checks if the command ``commandName`` is registered|

|``void`` RegisterCommand(``string`` name, ``function`` command, ~~``string`` sourceModule~~)|
|---|
|Registers a command using the command dictionary. Names must be unique between all commands.
An example of a command would look like|
```lua
--taken from DCOMM.lua
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
}
```
|``void`` RunCommand(``string`` name, ``dictionary`` metadata)|
|---|
|Executes a command's function by name, Metadata is information for the command to use, if this is correctly handled, Response will provide this metadata for you|

|``void`` UnregisterCommand(``string`` name)|
|---|
|Removes a command by name.|

# PluginManager

### Properties

|``dictionary`` Plugins|
|---|
|Reference to all installed plugins|

### Functions
|``void`` InvokePlayerAdded(``Instance<player>`` player)|
|---|
|Invokes .PlayerAdded(player) on all running plugins.|

|``void`` InvokePlayerRemoving(``Instance<player>`` player)|
|---|
|Invokes .PlayerRemoving(player) on all running plugins.|

|``void`` QuickRun(``dictionary`` pluginMetadata)
|---|
|Initialises and starts up a plugin without registering it|

|``void`` RegisterPlugin(``string`` name, ``dictionary`` pluginMetadata)
|---|
|Registers a plugin to ``name`` and calls Initialise. Plugin names must be unique|

|``void`` StartAllPlugins()|
|---|
|Calls start on all registered plugins|

|``void`` UnregisterPlugin(``string`` name)|
|---|
|Stops a plugin by calling .Stop() and then unregisters it|

# util
util is unlike the other APIs and provides a selection of helper functions. It is still accesible like the rest of the APIs

|``void`` util:AppendTable(``table`` t1, ``table`` t2)|
|---|
|Appends the contents of t2 into t1|

|``dictionary`` util:ParseCommand(``string`` text)
|---|
|Runs text against the command parser, then returns metadata|

|``void`` util:ProcessArguments(``table`` Arguments, ``table`` targetTable, ``string`` dominantKey, ``function`` callback)
|---|
|Runs a check against targetTable using the arguments table, checking the dominant key for a check, finishing by invoking the callback with the said argument|

|``void`` util:Wildcard(``table`` Arguments, ``table`` targetTable, ``string`` wildcard)
|---|
|Runs a predefined wildcard function against targetTable using the arguments as a filter. Currently, the only two defined wildcards are ``@a`` and ``@r``|
