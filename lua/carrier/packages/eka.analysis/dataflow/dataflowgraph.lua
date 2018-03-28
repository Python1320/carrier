local self = {}
Analysis.DataFlowGraph = Class (self)

function self:ctor ()
	self.NodeSet           = {}
	self.NodeAddresses     = {}
	
	self.InputNodeSet      = {}
	self.OutputNodeSet     = {}
	self.OutputNodes       = {}
	self.OutputNodesSorted = true
	
	self.InputNodeCount    = 0
	self.NodeCount         = 0
end

function self:AddNode (node, address)
	assert (address)
	
	if not self.NodeSet [node] then
		self.NodeSet [node] = true
		self.NodeCount = self.NodeCount + 1
	end
	
	self.NodeAddresses [node] = address
end

function self:AddInputNode (node, address)
	if not self.InputNodeSet [node] then
		self.InputNodeSet [node] = true
		self.InputNodeCount = self.InputNodeCount + 1
	end
	
	self:AddNode (node, address)
end

function self:AddOutputNode (node, address)
	if not self.OutputNodeSet [node] then
		self.OutputNodeSet [node] = true
		self.OutputNodes [#self.OutputNodes + 1] = node
		if self.OutputNodesSorted and
		   #self.OutputNodes > 1 and
		   address < self.NodeAddresses [self.OutputNodes [#self.OutputNodes - 1]] then
			self.OutputNodesSorted = false
		end
	end
	
	self:AddNode (node, address)
end

function self:GetNodeAddress (node)
	return self.NodeAddresses [node]
end

function self:GetNodeCount ()
	return self.NodeCount
end

function self:GetInputNodeCount ()
	return self.InputNodeCount
end

function self:GetOutputNodeCount ()
	return #self.OutputNodes
end

function self:GetInternalNodeCount ()
	return self.NodeCount - self.InputNodeCount - #self.OutputNodes
end

function self:GetNodeEnumerator ()
	return KeyEnumerator (self.NodeSet)
end

function self:GetInputNodeEnumerator ()
	return KeyEnumerator (self.InputNodeSet)
end

function self:GetOutputNodeEnumerator ()
	if not self.OutputNodesSorted then
		table.sort (self.OutputNodes,
			function (a, b)
				return self.NodeAddresses [a] < self.NodeAddresses [b]
			end
		)
	end
	
	return ArrayEnumerator (self.OutputNodes)
end

function self:IsInputNode (node)
	return self.InputNodeSet [node] or false
end

function self:IsOutputNode (node)
	return self.OutputNodeSet [node] or false
end
