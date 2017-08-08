local self = {}
GarrysMod.HorizontalScrollbar = Class (self, Scrollbar)

function self:ctor ()
	self.LeftButton = Scrollbar.Button (Glass.Direction.Left)
	self.LeftButton:SetParent (self)
	self.LeftButtonBehaviour = Scrollbar.ButtonBehaviour (self, self.LeftButton, -1)
	self.RightButton = Scrollbar.Button (Glass.Direction.Right)
	self.RightButton:SetParent (self)
	self.RightButtonBehaviour = Scrollbar.ButtonBehaviour (self, self.RightButton, 1)
	
	self.Grip = Scrollbar.Grip (Glass.Orientation.Horizontal)
	self.Grip:SetParent (self)
end

-- IView
-- Content layout
function self:GetPreferredSize (maximumWidth, maximumHeight)
	return maximumWidth or self:GetWidth (), self:GetThickness ()
end

-- Internal
function self:OnLayout (w, h)
	self.LeftButton:SetRectangle (0, 0, h, h)
	self.RightButton:SetRectangle (w - h, 0, h, h)
	
	self.Grip:SetRectangle (h + self:ScrollPositionToGripPosition (self:GetAnimatedScrollPosition ()), 0, self:GetGripSize (), h)
end

-- Scrollbar
function self:GetOrientation ()
	return Glass.Orientation.Horizontal
end

function self:GetTrackSize ()
	return self:GetWidth () - self:GetHeight () * 2
end

-- HorizontalScrollbar
function self:ScrollLeft (animated)
	self:ScrollSmallIncrements (-1, animated)
end

function self:ScrollRight (animated)
	self:ScrollSmallIncrements (1, animated)
end
