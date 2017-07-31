Glass = {}

Error = require ("Pylon.Error")

OOP = require ("Pylon.OOP")
OOP.Initialize (_ENV)

Enumeration = require ("Pylon.Enumeration")
Enumeration.Initialize (_ENV)

ICollection = require ("Pylon.Containers.ICollection")

Color = require ("Pylon.Color")

include ("fonts/ifont.lua")
include ("fonts/fontweight.lua")

include ("layout/horizontalalignment.lua")
include ("layout/verticalalignment.lua")
include ("layout/orientation.lua")
include ("layout/direction.lua")

include ("mouse/cursor.lua")
include ("mouse/mousebuttons.lua")

include ("behaviours/buttonbehaviour.lua")

include ("iview.lua")
include ("iwindow.lua")

include ("containers/listview.lua")
include ("containers/ilistviewdatasource.lua")
include ("containers/listviewitem.lua")
include ("containers/listview.internaldatasource.lua")
include ("containers/tableview.lua")
include ("containers/tableview.listviewitem.lua")
include ("containers/tableview.internaldatasource.lua")
include ("containers/tableview.header.lua")
include ("containers/tableview.columnview.lua")
include ("containers/tableview.columncollection.lua")
include ("containers/itableviewdatasource.lua")
include ("containers/tableviewcolumn.lua")
include ("containers/tableviewcolumntype.lua")
include ("containers/treetableview.lua")

function Glass.Initialize (destinationTable)
	destinationTable = destinationTable or {}
	
	destinationTable.IFont               = Glass.IFont
	destinationTable.FontWeight          = Glass.FontWeight
	
	destinationTable.HorizontalAlignment = Glass.HorizontalAlignment
	destinationTable.VerticalAlignment   = Glass.VerticalAlignment
	destinationTable.Orientation         = Glass.Orientation
	destinationTable.Direction           = Glass.Direction
	
	destinationTable.Cursor              = Glass.Cursor
	destinationTable.MouseButtons        = Glass.MouseButtons
	destinationTable.IView               = Glass.IView
	destinationTable.IWindow             = Glass.IWindow
	
	destinationTable.IListViewDataSource = Glass.IListViewDataSource
	
	return destinationTable
end

return Glass
