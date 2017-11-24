local self = {}
PackageFile.SignatureSection = Class (self, PackageFile.Section)
PackageFile.SignatureSection.Name = "signature"

function self:ctor ()
	self.SectionNames   = {}
	self.SectionMD5s    = {}
	self.SectionSHA256s = {}
end

-- ISerializable
function self:Serialize (streamWriter)
	streamWriter:StringN32 (self.Signature)
	
	streamWriter:UInt32 (#self.SectionNames)
	for i = 1, #self.SectionNames do
		streamWriter:StringN8 (self.SectionNames   [i])
		streamWriter:Bytes    (self.SectionMD5s    [i])
		streamWriter:Bytes    (self.SectionSHA256s [i])
	end
end

function self:Deserialize (streamReader)
	self.Signature = streamReader:StringN32 ()
	
	local sectionHashCount = streamReader:UInt32 ()
	for i = 1, sectionHashCount do
		local sectionName = streamReader:StringN8 ()
		local md5         = streamReader:Bytes (16)
		local sha256      = streamReader:Bytes (32)
		self:AddSectionHash (sectionName, md5, sha256)
	end
end

-- ISection
function self:GetName ()
	return PackageFile.SignatureSection.Name
end

-- SignatureSection
function self:AddSectionHash (sectionName, md5, sha256)
	self.SectionNames   [#self.SectionNames   + 1] = sectionName
	self.SectionMD5s    [#self.SectionMD5s    + 1] = md5
	self.SectionSHA256s [#self.SectionSHA256s + 1] = sha256
end

function self:GetSectionHash (i)
	return self.SectionNames [i], self.SectionMD5s [i], self.SectionSHA256s [i]
end

function self:GetSectionHashCount ()
	return #self.SectionNames
end
