local self = {}
Analysis.DataFlowGraph.OutputNode = Class (self, Analysis.DataFlowGraph.ExternalNode)

function self:ctor (address)
	self.DataFlowNode = nil
end

-- Node
function self:EvaluateConstant (inputSubstitutionMap, cachingEvaluator)
	return cachingEvaluator (self.DataFlowNode, inputSubstitutionMap)
end

function self:GetDependencies (out)
	local out = out or {}
	out [#out + 1] = self.DataFlowNode
	return out
end

-- OutputNode
function self:GetDataFlowNode ()
	return self.DataFlowNode
end
