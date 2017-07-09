GarrysMod = {}

require ("Pylon.OOP").Initialize (_ENV)

Core = require ("Phoenix.Core")
Core.Initialize (_ENV)

Photon = require ("Photon")

Clock = require ("Pylon.MonotonicClock")

include ("cursor.lua")
include ("mousebuttons.lua")

include ("panelviews.lua")

include ("view.lua")
include ("window.lua")
include ("window.restorebutton.lua")
include ("label.lua")

include ("externalview.lua")

function GarrysMod.Initialize (destinationTable)
	destinationTable = destinationTable or {}
	
	Core.Initialize (destinationTable)
	
	destinationTable.View   = GarrysMod.View
	destinationTable.Window = GarrysMod.Window
	destinationTable.Label  = GarrysMod.Label
	
	return destinationTable
end

return GarrysMod
