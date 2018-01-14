local self = {}
Analysis.DataFlowGraph.BinaryOperatorNode = Class (self, Analysis.DataFlowGraph.Node)

function self:ctor (address, operator, leftDataFlowNode, rightDataFlowNode)
	self.Operator = operator
	
	self.LeftDataFlowNode  = leftDataFlowNode
	self.RightDataFlowNode = rightDataFlowNode
end

-- Node
function self:EvaluateConstant (inputSubstitutionMap, cachingEvaluator)
	local left  = cachingEvaluator (self.LeftDataFlowNode,  inputSubstitutionMap)
	local right = cachingEvaluator (self.RightDataFlowNode, inputSubstitutionMap)
	if left and right then
		return self.Operator:Evaluate (left, right)
	end
	return nil
end

function self:GetOperator ()
	return self.Operator
end

function self:ToString ()
	local leftExpression  = self.LeftDataFlowNode:ToString ()
	local rightExpression = self.RightDataFlowNode:ToString ()
	if self.LeftDataFlowNode:GetOperator () and
	   (self.LeftDataFlowNode:GetOperator () ~= self.Operator or not self.Operator:IsAssociative ()) and
	   self.LeftDataFlowNode:GetOperator ():GetPrecedence () >= self.Operator:GetPrecedence () and
	   self.LeftDataFlowNode:GetOperator ():GetAssociativity () ~= AST.Associativity.Left then
		leftExpression = "(" .. leftExpression .. ")"
	end
	if self.RightDataFlowNode:GetOperator () and
	   (self.RightDataFlowNode:GetOperator () ~= self.Operator or not self.Operator:IsAssociative ()) and
	   self.RightDataFlowNode:GetOperator ():GetPrecedence () >= self.Operator:GetPrecedence () and
	   self.RightDataFlowNode:GetOperator ():GetAssociativity () ~= AST.Associativity.Right then
		rightExpression = "(" .. rightExpression .. ")"
	end
	
	return leftExpression .. " " .. self.Operator:GetSymbol () .. " " .. rightExpression
end

-- BinaryOperatorNode
function self:GetLeftDataFlowNode ()
	return self.LeftDataFlowNode
end

function self:GetRightDataFlowNode ()
	return self.RightDataFlowNode
end
