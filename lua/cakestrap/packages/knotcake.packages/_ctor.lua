Packages = {}

Error = CakeStrap.LoadPackage ("Knotcake.Error")
OOP   = CakeStrap.LoadPackage ("Knotcake.OOP")
OOP.Initialize (_ENV)

IO = {}
CakeStrap.LoadProvider ("Knotcake.IO").Initialize (IO)

Enumeration = CakeStrap.LoadPackage ("Knotcake.Enumeration")
Enumeration.Initialize (_ENV)

HTTP = CakeStrap.LoadProvider ("Knotcake.HTTP")

Text = CakeStrap.LoadPackage ("Knotcake.Text")
Util = CakeStrap.LoadPackage ("Knotcake.Util")

include ("packagerepositoryinformation.lua")
include ("packageinformation.lua")
include ("packagereleaseinformation.lua")
include ("packagereference.lua")

include ("packagemanager.lua")
include ("packagemanager.repositorylistserializer.lua")
include ("packagerepository.lua")
include ("packagerepository.metadataserializer.lua")
include ("packagerepository.manifestserializer.lua")
include ("package.lua")
include ("packagerelease.lua")

return Packages
