local self = {}
GarrysMod.Environment = Class (self, Glass.IEnvironment)

function self:ctor ()
	self.HandleViews = setmetatable ({}, { __mode = "k" })
end

-- IEnvironment
function self:GetGraphicsContext ()
	return Photon.GraphicsContext
end

function self:GetTextRenderer ()
	return Photon.TextRenderer
end

function self:CreateHandle (view)
	local handle = vgui.Create ("DPanel")
	
	self:SetRectangle (view, handle, view:GetRectangle ())
	if not view:IsVisible () then
		self:SetVisible (view, handle, view:IsVisible ())
	end
	if view:GetCursor () ~= Glass.Cursor.Default then
		self:SetCursor (view, handle, view:GetCursor ())
	end
	
	self:InstallPanelEvents (view, handle)
	self:RegisterView (handle, view)
	
	return handle
end

function self:CreateWindowHandle (view)
	local handle = vgui.Create ("DFrame")
	
	self:InstallPanelEvents (view, handle)
	self:RegisterView (handle, view)
	
	return handle
end

function self:CreateLabelHandle (view)
	local handle = vgui.Create ("DLabel")
	
	self:InstallPanelEvents (view, handle)
	self:RegisterView (handle, view)
	
	self:SetLabelText (view, handle, view:GetText ())
	self:SetLabelFont (view, handle, view:GetFont ())
	self:SetLabelTextColor (view, handle, view:GetTextColor ())
	self:SetLabelHorizontalAlignment (view, handle, view:GetHorizontalAlignment ())
	-- self:SetLabelVerticalAlignment (view, handle, view:GetVerticalAlignment ())
	-- No need to update vertical alignment, since both alignments are updated simultaneously
	
	return handle
end

function self:DestroyHandle (view, handle)
	self:UnregisterView (view, handle)
	
	if handle and handle:IsValid () then
		handle:Remove ()
	end
end

-- View
-- Hierarchy
function self:AddChild (view, handle, childView)
	childView:GetHandle ():SetParent (handle)
end

function self:RemoveChild (view, handle, childView)
	childView:GetHandle ():SetParent (nil)
end

function self:GetParent (view, handle)
	return self:GetView (handle:GetParent ())
end

function self:SetParent (view, handle, parentHandle)
	handle:SetParent (parentHandle)
end

-- Bounds
function self:GetRectangle (view, handle)
	local x, y = self:GetPosition (view, handle)
	local w, h = self:GetSize (view, handle)
	return x, y, w, h
end

function self:GetPosition (view, handle)
	local parentView = self:GetView (handle:GetParent ())
	local dx, dy = 0, 0
	if parentView then dx, dy = parentView:GetContainerPosition () end
	
	local x, y = handle:GetPos ()
	return x - dx, y - dy
end

function self:GetSize (view, handle)
	return handle:GetSize ()
end

function self:SetRectangle (view, handle, x, y, w, h)
	self:SetPosition (view, handle, x, y)
	self:SetSize     (view, handle, w, h)
end

function self:SetPosition (view, handle, x, y)
	local parentView = self:GetView (handle:GetParent ())
	local dx, dy = 0, 0
	if parentView then dx, dy = parentView:GetContainerPosition () end
	
	handle:SetPos (x + dx, y + dy)
end

function self:SetSize (view, handle, w, h)
	handle:SetSize (w, h)
end

-- Layout
function self:BringToFront (view, handle)
	handle:MoveToFront ()
end

function self:MoveToBack (view, handle)
	handle:MoveToBack ()
end

function self:InvalidateLayout (view, handle)
	handle:InvalidateLayout ()
end

-- Appearance
function self:IsVisible (view, handle)
	return handle:IsVisible ()
end

function self:SetVisible (view, handle, visible)
	handle:SetVisible (visible)
end

-- Mouse
function self:GetCursor (view, handle)
	return view:GetCursor ()
end

function self:SetCursor (view, handle, cursor)
	handle:SetCursor (Cursor.ToNative (cursor))
end

function self:GetMousePosition (view, handle)
	local x, y = handle:CursorPos ()
	
	-- Fix coordinates by inverting the bad ScreenToLocal transform
	-- This happens when view layout is done outside of a legitimate layout event
	x, y = handle:LocalToScreen (x, y)
	
	-- Manual ScreenToLocal
	local panel = handle
	while panel do
		local dx, dy = panel:GetPos ()
		x, y = x - dx, y - dy
		
		panel = panel:GetParent ()
	end
	
	return x, y
end

function self:CaptureMouse (view, handle)
	MouseEventRouter:OnCaptureMouse (view)
	handle:MouseCapture (true)
end

function self:ReleaseMouse (view, handle)
	handle:MouseCapture (false)
	MouseEventRouter:OnReleaseMouse (view)
end

-- Animations
function self:AddAnimation (view, handle, animation)
	if handle.ThinkHandlerInstalled then return end
	
	handle.ThinkHandlerInstalled = true
	
	local defaultThink = handle.Think
	handle.Think = function (_)
		if defaultThink then
			defaultThink (_)
		end
		
		-- Run animations
		local t = Clock ()
		view:UpdateAnimations (t)
		
		-- Remove Think handler if all
		-- animations have completed
		if view:GetAnimationCount () == 0 then
			handle.Think = defaultThink
			handle.ThinkHandlerInstalled = false
		end
	end
end

function self:RemoveAnimation (view, handle, animation)
end

-- Label
function self:GetLabelPreferredSize (view, handle, maximumWidth, maximumHeight)
	return handle:GetContentSize (maximumWidth, maximumHeight)
end

function self:GetLabelText (view, handle)
	return handle:GetText ()
end

function self:GetLabelFont (view, handle)
	return view:GetFont ()
end

function self:GetLabelTextColor (view, handle)
	return view:GetTextColor ()
end

function self:GetHorizontalAlignment (view, handle)
	return view:GetHorizontalAlignment ()
end

function self:GetVerticalAlignment (view, handle)
	return view:GetVerticalAlignment ()
end

function self:SetLabelText (view, handle, text)
	handle:SetText (text)
end

function self:SetLabelFont (view, handle, font)
	handle:SetFont (font:GetId ())
end

function self:SetLabelTextColor (view, handle, textColor)
	handle:SetTextColor (_G.Color (Color.ToRGBA8888 (textColor)))
end

function self:SetLabelHorizontalAlignment (view, handle, horizontalAlignment)
	handle:SetContentAlignment (ContentAlignment.FromAlignment (horizontalAlignment, view:GetVerticalAlignment ()))
	
	handle:SetTextInset (self.HorizontalAlignment == Glass.HorizontalAlignment.Right and 1 or 0, 0)
end

function self:SetLabelVerticalAlignment (view, handle, verticalAlignment)
	handle:SetContentAlignment (ContentAlignment.FromAlignment (view:GetHorizontalAlignment (), verticalAlignment))
end

-- Environment
function self:GetView (handle)
	local view = self.HandleViews [handle]
	if view then return view end
	
	if not handle or
	   not handle:IsValid () then
		return nil
	end
	
	view = ExternalView (handle)
	self:RegisterView (handle, view)
	
	return view
end

function self:RegisterView (handle, view)
	self.HandleViews [handle] = view
end

function self:UnregisterView (handle, view)
	self.HandleViews [handle] = nil
end

-- Internal
function self:InstallPanelEvents (view, handle)
	handle.OnMousePressed = function (_, mouseCode)
		local mouseButtons = MouseButtons.FromNative (mouseCode)
		MouseEventRouter:OnMouseDown (view, mouseButtons, view:GetMousePosition ())
	end
	
	handle.OnMouseReleased = function (_, mouseCode)
		local mouseButtons = MouseButtons.FromNative (mouseCode)
		MouseEventRouter:OnMouseUp (view, mouseButtons, view:GetMousePosition ())
	end
	
	handle.OnMouseWheeled = function (_, delta)
		return MouseEventRouter:OnMouseWheel (view, delta)
	end
	
	handle.OnCursorMoved = function (_, x, y)
		local mouseButtons = MouseButtons.Poll ()
		MouseEventRouter:OnMouseMove (view, mouseButtons, view:GetMousePosition ())
	end
	
	handle.OnCursorEntered = function (_)
		MouseEventRouter:OnMouseEnter (view)
	end
	
	handle.OnCursorExited = function (_)
		MouseEventRouter:OnMouseLeave (view)
	end
	
	handle.Paint = function (_, w, h)
		view:Render (w, h, Photon.Render2d)
	end
	
	local performLayout = handle.PerformLayout
	handle.PerformLayout = function (handle, w, h)
		if performLayout then
			performLayout (handle, w, h)
		end
		
		view:OnLayout (view:GetContainerSize ())
		view.Layout:Dispatch ()
	end
	
	local setVisible = handle.SetVisible
	handle.SetVisible = function (handle, visible)
		if handle:IsVisible () == visible then return end
		
		setVisible (handle, visible)
		
		if view:IsVisible () ~= visible then
			view:SetVisible (visible)
		end
	end
	
	local onRemoved = handle.OnRemoved
	handle.OnRemoved = function (handle)
		onRemoved (handle)
		
		self:UnregisterView (handle, view)
		view:OnHandleDestroyed ()
	end
end

GarrysMod.Environment = GarrysMod.Environment ()
