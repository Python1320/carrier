local self = {}
Core.IView = Interface (self)

function self:ctor ()
end

-- Hierarchy
function self:AddChild (view)
	Error ("IView:AddChild : Not implemented.")
end

function self:RemoveChild (view)
	Error ("IView:RemoveChild : Not implemented.")
end

function self:GetParent ()
	Error ("IView:GetParent : Not implemented.")
end

function self:SetParent (view)
	Error ("IView:SetParent : Not implemented.")
end

-- Layout
function self:GetPosition ()
	Error ("IView:GetPosition : Not implemented.")
end

function self:SetPosition (x, y)
	Error ("IView:SetPosition : Not implemented.")
end

function self:GetSize ()
	Error ("IView:GetSize : Not implemented.")
end

function self:SetSize (w, h)
	Error ("IView:SetSize : Not implemented.")
end

function self:Center ()
	Error ("IView:Center : Not implemented.")
end

-- Appearance
function self:IsVisible ()
	Error ("IView:IsVisible : Not implemented.")
end

function self:SetVisible (visible)
	Error ("IView:SetVisible : Not implemented.")
end

-- Internal
function self:OnLayout ()
end
