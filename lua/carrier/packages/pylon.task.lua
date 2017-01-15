local Task = {}

local f           = Carrier.LoadPackage ("Pylon.Functional")

local CompactList = Carrier.LoadPackage ("Pylon.Structures.CompactList")
local Future      = Carrier.LoadPackage ("Pylon.Future")

function Task.RunCallback (f, ...)
	local argumentCount, arguments = CompactList.Pack (...)
	
	-- Append callback function
	local future = Future ()
	argumentCount, arguments = CompactList.Append (argumentCount, arguments,
		function (...)
			future:Resolve (...)
		end
	)
	
	f (CompactList.Unpack (argumentCount, arguments))
	
	return future
	
end

Task.WrapCallback = f.Curry (f.Curry, Task.RunCallback)

function Task.Run (f, ...)
	local future = Future ()
	
	coroutine.wrap (
		function (...)
			future:Resolve (f (...))
		end
	) (...)
	
	return future
end

Task.Wrap = f.Curry (f.Curry, Task.Run)

return Task
