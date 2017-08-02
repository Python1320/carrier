local self = {}
MouseEventRouter = Class (self)

function self:ctor ()
	self.HoveredView = nil
	self.MouseCaptureView = nil
	
	self.LastClickTime = -math.huge
end

function self:OnCaptureMouse (view)
	self.MouseCaptureView = view
	self:SetHoveredView (self.MouseCaptureView)
end

function self:OnReleaseMouse (view)
	if self.MouseCaptureView == view then
		self.MouseCaptureView = nil
		self:SetHoveredView (PanelViews.GetView (vgui.GetHoveredPanel ()))
	end
end

function self:OnMouseDown (view, mouseButtons, x, y)
	return self:BubbleButtonEvent (view, "OnMouseDown", "MouseDown", mouseButtons, x, y)
end

function self:OnMouseMove (view, mouseButtons, x, y)
	return self:BubbleButtonEvent (view, "OnMouseMove", "MouseMove", mouseButtons, x, y)
end

function self:OnMouseUp (view, mouseButtons, x, y)
	local handled = self:Dispatch (view, "OnMouseUp", "MouseUp", mouseButtons, x, y)
	
	if mouseButtons == Glass.MouseButtons.Left then
		if Clock () - self.LastClickTime > 0.2 then
			self:OnClick (view)
		else
			self:OnDoubleClick (view)
		end
	end
	
	if handled then return handled end
	local view, x, y = self:ToParent (view, x, y)
	return self:BubbleButtonEvent (view, "OnMouseUp", "MouseUp", mouseButtons, x, y)
end

function self:OnMouseWheel (view, delta)
	return self:Dispatch (view, "OnMouseWheel", "MouseWheel", delta)
end

function self:OnMouseEnter (view)
	if self.MouseCaptureView then return end
	
	-- view is not necessarily the view with mouse focus
	-- if a bunch of layout is going on.
	self:SetHoveredView (PanelViews.GetView (vgui.GetHoveredPanel ()))
end

function self:OnMouseLeave (view)
	if self.MouseCaptureView then return end
	
	self:SetHoveredView (PanelViews.GetView (vgui.GetHoveredPanel ()))
end

-- Internal
function self:OnClick (view)
	self.LastClickTime = Clock ()
	
	return self:BubbleEvent (view, "OnClick", "Click")
end

function self:OnDoubleClick (view)
	self.LastClickTime = -math.huge
	
	return self:BubbleEvent (view, "OnDoubleClick", "DoubleClick")
end

function self:Dispatch (view, methodName, eventName, ...)
	local handled1 = view [methodName] (view, ...)
	local handled2 = view [eventName]:Dispatch (...)
	return handled1 or handled2
end

function self:BubbleEvent (view, methodName, eventName)
	while view do
		local handled = self:Dispatch (view, methodName, eventName)
		if handled then return handled end
		
		view = view:GetParent ()
	end
	
	return false
end

function self:BubbleButtonEvent (view, methodName, eventName, mouseButtons, x, y)
	while view do
		local handled = self:Dispatch (view, methodName, eventName, mouseButtons, x, y)
		if handled then return handled end
		
		view, x, y = self:ToParent (view, x, y)
	end
	
	return false
end

function self:SetHoveredView (view)
	if self.HoveredView == view then return end
	
	self.LastClickTime = -math.huge
	
	local previousStack = {}
	local currentStack  = {}
	
	local previousView = self.HoveredView
	self.HoveredView = view
	
	-- Compute previous ancestry stack (reversed)
	local previousView = previousView
	while previousView do
		previousStack [#previousStack + 1] = previousView
		previousView = previousView:GetParent ()
	end
	
	-- Compute new ancestry stack (reversed)
	local currentView = self.HoveredView
	while currentView do
		currentStack [#currentStack + 1] = currentView
		currentView = currentView:GetParent ()
	end
	
	-- Find common ancestor
	local lastCommonAncestorIndex = 0
	for i = 1, #previousStack do
		if previousStack [#previousStack - i + 1] ~= currentStack [#currentStack - i + 1] then
			break
		end
		lastCommonAncestorIndex = lastCommonAncestorIndex + 1
	end
	
	-- Dispatch MouseLeaves upwards from the bottom of previousStack
	for i = 1, #previousStack - lastCommonAncestorIndex do
		self:Dispatch (previousStack [i], "OnMouseLeave", "MouseLeave")
	end
	-- Dispatch MouseEnters downwards from lastCommonAncestorIndex
	for i = #currentStack - lastCommonAncestorIndex, 1, -1 do
		self:Dispatch (currentStack [i], "OnMouseEnter", "MouseEnter")
	end
end

function self:ToParent (view, x, y)
	local dx, dy = view:GetPosition ()
	x = x + dx
	y = y + dy
	
	local parent = view:GetParent ()
	if parent then
		dx, dy = parent:GetContainerPosition ()
		x = x + dx
		y = y + dy
	end
	
	return parent, x, y
end

MouseEventRouter = MouseEventRouter ()
