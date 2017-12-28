local self = {}
Cat.Rings.Reals = Class (self, Cat.Rings.IRing)

function self:ctor ()
end

-- Equality
function self:Equals (a, b) return a == b end

-- Arithmetic
function self:Add      (a, b, out) return a + b end
function self:Subtract (a, b, out) return a - b end
function self:Multiply (a, b, out) return a * b end
function self:Divide   (a, b, out) return a / b end

-- Identities
function self:AdditiveIdentity       (out) return 0 end
function self:MultiplicativeIdentity (out) return 1 end

function self:IsAdditiveIdentity       (x) return x == 0 end
function self:IsMultiplicativeIdentity (x) return x == 1 end

-- Inverses
function self:AdditiveInverse (x, out)
	return -x
end

function self:MultiplicativeInverse (x, out)
	return 1 / x
end
