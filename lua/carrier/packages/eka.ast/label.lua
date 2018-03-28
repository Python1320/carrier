local self = {}
AST.Label = Class (self, AST.Statement)

function self:ctor (identifier)
	self.Identifier = identifier
end

-- Node
function self:GetChildEnumerator ()
	return SingleValueEnumerator (self.Identifier)
end

function self:ToString ()
	return self.Identifier:ToString () .. ":"
end

-- Label
function self:GetIdentifier ()
	return self.Identifier
end

function self:SetIdentifier (identifier)
	self.Identifier = identifier
end
