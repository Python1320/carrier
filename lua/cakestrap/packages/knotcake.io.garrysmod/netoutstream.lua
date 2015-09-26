local self = {}
GarrysMod.NetOutStream = GarrysMod.Class (self, GarrysMod.IO.StreamWriter)

function self:ctor ()
end

-- IBaseStream
function self:Close ()
end

function self:GetPosition ()
	return net.BytesWritten ()
end

function self:GetSize ()
	return net.BytesWritten ()
end

function self:SeekAbsolute (seekPos)
	seekPos = math.max (seekPos, self:GetSize ())
	
	GarrysMod.Error ("NetOutStream:SeekAbsolute : Not supported.")
end

-- IOutStream
function self:Write (data, size)
	net.WriteData (data, size)
end	

-- IStreamWriter
function self:UInt8    (n) net.WriteUInt (n,  8) end
function self:UInt8LE  (n) net.WriteUInt (n,  8) end
function self:UInt8BE  (n) net.WriteUInt (n,  8) end

function self:Int8     (n) net.WriteInt  (n,  8) end
function self:Int8LE   (n) net.WriteInt  (n,  8) end
function self:Int8BE   (n) net.WriteInt  (n,  8) end

function self:UInt16LE (n) net.WriteUInt (n, 16) end
function self:Int16LE  (n) net.WriteInt  (n, 16) end

function self:UInt32LE (n) net.WriteUInt (n, 32) end
function self:Int32LE  (n) net.WriteInt  (n, 32) end

function self:FloatLE  (f) net.WriteFloat  (f) end
function self:DoubleLE (f) net.WriteDouble (f) end

function self:Char     (c) net.WriteData (c,  1) end

-- StreamWriter
function self:UInt81 (uint80)
	local uint8 = GarrysMod.BitConverter.UInt8sToUInt8 (uint80)
	net.WriteUInt (uint8, 8)
end

function self:UInt82 (uint80, uint81)
	local uint16 = GarrysMod.BitConverter.UInt8sToUInt16 (uint80, uint81)
	net.WriteUInt (uint16, 16)
end

function self:UInt84 (uint80, uint81, uint82, uint83)
	local uint32 = GarrysMod.BitConverter.UInt8sToUInt32 (uint80, uint81, uint82, uint83)
	net.WriteUInt (uint32, 32)
end

function self:UInt88 (uint80, uint81, uint82, uint83, uint84, uint85, uint86, uint87)
	self:UInt84 (uint80, uint81, uint82, uint83)
	self:UInt84 (uint84, uint85, uint86, uint87)
end
