local self = {}
AST.Statements.Goto = Class (self, AST.Statement)

function self:ctor (identifier)
	self.Identifier = identifier
end

-- Node
function self:GetChildEnumerator ()
	return SingleValueEnumerator (self.Identifier)
end

function self:ToString ()
	return "goto " .. self.Identifier:ToString () .. ";"
end

-- Statement
function self:IsControlFlowDiscontinuity ()
	return true
end

-- Goto
function self:GetIdentifier ()
	return self.Identifier
end

function self:SetIdentifier (identifier)
	self.Identifier = identifier
end
