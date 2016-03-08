GarrysMod = {}

Error = CakeStrap.LoadPackage ("Knotcake.Error")

OOP = CakeStrap.LoadPackage ("Knotcake.OOP")
OOP.Initialize (_ENV)

Text = CakeStrap.LoadPackage ("Knotcake.Text")
Text.Initialize (GarrysMod)

include ("util.lua")
include ("linebufferedtextsink.lua")

include ("consoletextsink.lua")
include ("chattextsink.lua")
include ("remotechattextsink.lua")

function GarrysMod.Initialize (destinationTable)
	destinationTable = destinationTable or {}
	
	destinationTable = Text.Initialize (destinationTable)
	
	destinationTable.ConsoleTextSink    = GarrysMod.ConsoleTextSink
	destinationTable.ChatTextSink       = GarrysMod.ChatTextSink
	destinationTable.RemoteChatTextSink = GarrysMod.RemoteChatTextSink
	
	return destinationTable
end

return GarrysMod
