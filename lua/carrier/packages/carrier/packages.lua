local self = {}
Carrier.Packages = Class (self)

function self:ctor ()
	self.Packages     = {}
	self.PackageCount = 0
	
	self.ManifestTimestamp = 0
	self.CacheDirectory = "garrysmod.io/carrier/cache"
	file.CreateDir (self.CacheDirectory)
	
	self.LoadRoots = {}
	self.LoadedPackages = {}
	
	self:UpdateLocalDeveloperPackages ()
end

local sv_allowcslua = GetConVar ("sv_allowcslua")
function self:Initialize ()
	local t0 = SysTime ()
	local autoloadSet = {}
	autoloadSet = Array.ToSet (file.Find ("carrier/autoload/*.lua", "LUA"), autoloadSet)
	if CLIENT and sv_allowcslua:GetBool () then
		autoloadSet = Array.ToSet (file.Find ("carrier/autoload/*.lua", "LCL"), autoloadSet)
	end
	if SERVER then
		autoloadSet = Array.ToSet (file.Find ("carrier/autoload/*.lua", "LSV"), autoloadSet)
	end
	
	for autoload in pairs (autoloadSet) do
		local f = CompileFile ("carrier/autoload/" .. autoload)
		if f then
			setfenv (f, {})
			
			for _, packageName in ipairs ({ f () }) do
				self.LoadRoots [packageName] = true
				self:Load (packageName)
			end
		end
	end
	local dt = SysTime () - t0
	Carrier.Log (string.format ("Initialize took %.2f ms", dt * 1000))
end

function self:Uninitialize ()
	for packageName, _ in pairs (self.LoadedPackages) do
		self:Unload (packageName)
	end
end

function self:Assimilate (package, packageRelease, environment, exports, destructor)
	package:Assimilate (packageRelease, environment, exports, destructor)
	self.LoadedPackages [package:GetName ()] = package
end

function self:Load (packageName)
	local package = self:GetPackage (packageName)
	if not package then
		Carrier.Warning ("Load: Package " .. packageName .. " not found!")
		return
	end
	
	self.LoadedPackages [packageName] = package
	return package:Load ()
end

function self:LoadProvider (packageName)
	return self:Load (packageName .. ".GarrysMod")
end

function self:Unload (packageName)
	local package = self.LoadedPackages [packageName]
	if not package then return end
	
	if package == true then
		Carrier.Warning ("Dependency cycle involving package " .. packageName .. "!")
		return
	end
	
	self.LoadedPackages [packageName] = true
	for dependentName, dependentVersion in package:GetLoadedRelease ():GetDependentEnumerator () do
		self:Unload (dependentName)
	end
	
	package:Unload ()
	self.LoadedPackages [packageName] = nil
end

function self:Update ()
	return Task.Run (
		function ()
			local response
			for i = 1, 5 do
				response = HTTP.Get ("https://garrysmod.io/api/packages/v1/latest"):await ()
				if response:IsSuccess () then break end
				
				Async.Sleep (1):await ()
			end
			
			if not response:IsSuccess () then return false end
			
			local response = util.JSONToTable (response:GetContent ())
			
			-- Check if already up to date
			if response.timestamp == self.ManifestTimestamp then return true end
			
			self.ManifestTimestamp = response.timestamp
			
			local packageReleaseSet = {}
			for packageName, packageInfo in pairs (response.packages) do
				local package = self:GetPackage (packageName) or Carrier.Package (packageName)
				package = package:FromJson (packageInfo)
				self:AddPackage (package)
				
				for packageReleaseVersion, packageReleaseInfo in pairs (packageInfo.releases) do
					if package:GetRelease (packageReleaseVersion) then
						package:GetRelease (packageReleaseVersion):SetDeprecated (false)
					else
						local packageRelease = Carrier.PackageRelease (packageName, packageReleaseVersion)
						packageReleaseSet [packageRelease] = true
						packageRelease = packageRelease:FromJson (packageReleaseInfo)
						package:AddRelease (packageRelease)
					end
				end
			end
			
			-- Populate dependents
			for packageRelease, _ in pairs (packageReleaseSet) do
				for dependencyName, dependencyVersion in packageRelease:GetDependencyEnumerator () do
					local dependency = self:GetPackageRelease (dependencyName, dependencyVersion)
					if dependency then
						dependency:AddDependent (packageRelease:GetName (), packageRelease:GetVersion ())
					end
				end
			end
			
			-- Deprecate old packages
			for package in self:GetPackageEnumerator () do
				for packageRelease in package:GetReleaseEnumerator () do
					if not packageRelease:IsDeveloper () and
					   not packageReleaseSet [packageRelease] then
						packageRelease:SetDeprecated (true)
					end
				end
			end
			
			return true
		end
	)
end

function self:UpdateLocalDeveloperPackages ()
	local pathId = CLIENT and "LCL" or "LSV"
	local files, folders = file.Find ("carrier/packages/*", pathId)
	
	local basePaths        = {}
	local constructorPaths = {}
	local destructorPaths  = {}
	for _, v in ipairs (files) do
		basePaths        [#basePaths        + 1] = "carrier/packages/" .. v
		constructorPaths [#basePaths]            = "carrier/packages/" .. v
		destructorPaths  [#basePaths]            = nil
	end
	for _, v in ipairs (folders) do
		basePaths        [#basePaths        + 1] = "carrier/packages/" .. v
		constructorPaths [#basePaths]            = "carrier/packages/" .. v .. "/_ctor.lua"
		destructorPaths  [#basePaths]            = "carrier/packages/" .. v .. "/_dtor.lua"
	end
	
	local dependencies = {}
	local replacements = {}
	for i = 1, #basePaths do
		local packageRelease, dependencySet, previousPackageRelease = self:UpdateLocalDeveloperPackage (basePaths [i], constructorPaths [i], destructorPaths [i], pathId)
		if packageRelease then
			dependencies [packageRelease] = dependencySet
			replacements [packageRelease] = previousPackageRelease
		end
	end
	
	-- Fixup dependencies
	for packageRelease, previousPackageRelease in pairs (replacements) do
		-- Replace in dependencies
		for dependentName, dependentVersion in previousPackageRelease:GetDependentEnumerator () do
			local dependent = self:GetPackageRelease (dependentName, dependentVersion)
			if dependent then
				dependent:RemoveDependency (previousPackageRelease:GetName (), previousPackageRelease:GetVersion ())
				dependent:AddDependency (packageRelease:GetName (), packageRelease:GetVersion ())
			end
		end
		
		-- Clear from dependents
		for dependencyName, dependencyVersion in previousPackageRelease:GetDependencyEnumerator () do
			local dependency = self:GetPackageRelease (dependencyName, dependencyVersion)
			if dependency then
				dependent:RemoveDependent (previousPackageRelease:GetName (), previousPackageRelease:GetVersion ())
			end
		end
	end
	
	-- Populate dependencies
	for packageRelease, dependencySet in pairs (dependencies) do
		for dependencyName, _ in pairs (dependencySet) do
			local dependencyPackage = self:GetPackage (dependencyName)
			local dependency = dependencyPackage and dependencyPackage:GetLocalDeveloperRelease ()
			if dependency then
				packageRelease:AddDependency (dependencyName, dependency:GetVersion ())
				dependency:AddDependent (packageRelease:GetName (), packageRelease:GetVersion ())
			end
		end
	end
end

-- Internal
function self:AddPackage (package)
	if self.Packages [package:GetName ()] then return end
	
	self.Packages [package:GetName ()] = package
	self.PackageCount = self.PackageCount + 1
end

function self:GetPackage (name)
	return self.Packages [name]
end

function self:GetPackageCount ()
	return self.PackageCount
end

function self:GetPackageEnumerator ()
	return ValueEnumerator (self.Packages)
end

function self:GetPackageRelease (name, version)
	local package = self.Packages [name]
	if not package then return end
	
	return package:GetRelease (version)
end

function self:ParsePackageConstructor (constructorPath, pathId)
	local code = file.Read (constructorPath, pathId)
	if not code then return nil, nil end
	local packageName = string.match (code, "%-%-%s*PACKAGE%s*([^%s]+)")
	if not packageName then return nil, nil end
	
	-- Parse dependencies
	local dependencySet = {}
	for require, packageName in string.gmatch (code, "(require_?p?r?o?v?i?d?e?r?)%s*%(?[\"']([^\"]-)[\"']%)?") do
		if require == "require" then
			dependencySet [packageName] = true
		elseif require == "require_provider" then
			dependencySet [packageName .. ".GarrysMod"] = true
		end
	end
	
	return packageName, dependencySet
end

function self:UpdateLocalDeveloperPackage (basePath, constructorPath, destructorPath, pathId)
	local packageName, dependencySet = self:ParsePackageConstructor (constructorPath, pathId)
	if not packageName then return nil, nil end
	
	local package = self:GetPackage (packageName)
	if not package then
		package = Carrier.Package (packageName)
		self:AddPackage (package)
	end
	
	local timestamp = file.Time (basePath, pathId)
	local destructorExists = destructorPath and file.Exists (destructorPath, pathId) or false
	local packageRelease = Carrier.LocalDeveloperPackageRelease (packageName, timestamp, basePath, constructorPath, destructorExists and destructorPath or nil, pathId)
	local previousPackageRelease = package:GetLocalDeveloperRelease ()
	package:RemoveRelease (previousPackageRelease)
	package:AddRelease (packageRelease)
	
	return packageRelease, dependencySet, previousPackageRelease
end
