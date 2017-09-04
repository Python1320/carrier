local UInt32 = {}

local bit_band   = bit.band
local bit_lshift = bit.lshift
local bit_rshift = bit.rshift
local math_floor = math.floor

UInt32.Minimum  = 0x00000000
UInt32.Maximum  = 0xFFFFFFFF
UInt32.BitCount = 32

-- Note: Branchless implementations of these operations with mods and divs
--       are faster than branching ones, except when the branch predictor
--       is always right.

-- ~14 ns
function UInt32.Add (a, b)
	local c = a + b
	return c % 4294967296, math_floor (c / 4294967296)
end

-- ~15 ns
function UInt32.AddWithCarry (a, b, cf)
	local c = a + b + cf
	return c % 4294967296, math_floor (c / 4294967296)
end

-- ~14 ns
function UInt32.Subtract (a, b)
	local c = a - b
	return c % 4294967296, -math_floor (c / 4294967296)
end

-- ~15 ns
function UInt32.SubtractWithBorrow (a, b, cf)
	local c = a - b - cf
	return c % 4294967296, -math_floor (c / 4294967296)
end

-- ~25 ns
function UInt32.Multiply (a, b)
	local a0, a1 = bit_band (a, 0xFFFF), bit_rshift (a, 16)
	local c0 = a0 * b
	local low, high = c0 % 4294967296, math_floor (c0 / 4294967296)
	
	local c1 = a1 * b
	low  = low  + bit_lshift (c1, 16)
	high = high + math_floor (c1 / 0x00010000)
	
	-- Carry
	high = high + math_floor (low / 4294967296)
	low  = low % 4294967296
	
	return low, high
end

function UInt32.MultiplyAdd1 (a, b, c)
	local a0, a1 = bit_band (a, 0xFFFF), bit_rshift (a, 16)
	local c0 = a0 * b
	local low, high = c0 % 4294967296 + c, math_floor (c0 / 4294967296)
	
	local c1 = a1 * b
	low  = low  + bit_lshift (c1, 16)
	high = high + math_floor (c1 / 0x00010000)
	
	-- Carry
	high = high + math_floor (low / 4294967296)
	low  = low % 4294967296
	
	return low, high
end
UInt32.MultiplyAdd = UInt32.MultiplyAdd1

function UInt32.MultiplyAdd2 (a, b, c, d)
	local a0, a1 = bit_band (a, 0xFFFF), bit_rshift (a, 16)
	local c0 = a0 * b
	local low, high = c0 % 4294967296 + c + d, math_floor (c0 / 4294967296)
	
	local c1 = a1 * b
	low  = low  + bit_lshift (c1, 16)
	high = high + math_floor (c1 / 0x00010000)
	
	-- Carry
	high = high + math_floor (low / 4294967296)
	low  = low % 4294967296
	
	return low, high
end

function UInt32.Divide (low, high, divisor)
	local q0, r0 = math_floor (low  / divisor), low  % divisor
	local q1, r1 = math_floor (high / divisor), high % divisor
	local q2, r2 = math_floor (4294967296 / divisor), 4294967296 % divisor
	local r = r0 + r1 * r2
	local q3, r3 = math_floor (r / divisor), r % divisor
	return q0 + q1 * q2 * divisor + r1 * q2 + r2 * q1 + q3, r3
end

UInt32.add = UInt32.Add
UInt32.adc = UInt32.AddWithCarry
UInt32.sub = UInt32.Subtract
UInt32.sbb = UInt32.SubtractWithBorrow
UInt32.mul = UInt32.Multiply
UInt32.div = UInt32.Divide

return UInt32
