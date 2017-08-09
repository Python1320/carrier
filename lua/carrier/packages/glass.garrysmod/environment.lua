local self = {}
GarrysMod.Environment = Class (self, Glass.IEnvironment)

local vgui_CreateX              = vgui.CreateX

local Panel = FindMetaTable ("Panel")
local Panel_CursorPos                 = Panel.CursorPos
local Panel_GetParent                 = Panel.GetParent
local Panel_GetPos                    = Panel.GetPos
local Panel_GetSize                   = Panel.GetSize
local Panel_GetText                   = Panel.GetText
local Panel_InvalidateLayout          = Panel.InvalidateLayout
local Panel_IsValid                   = Panel.IsValid
local Panel_IsVisible                 = Panel.IsVisible
local Panel_LocalToScreen             = Panel.LocalToScreen
local Panel_MouseCapture              = Panel.MouseCapture
local Panel_MoveToBack                = Panel.MoveToBack
local Panel_MoveToFront               = Panel.MoveToFront
local Panel_Remove                    = Panel.Remove
local Panel_SetContentAlignment       = Panel.SetContentAlignment
local Panel_SetCursor                 = Panel.SetCursor
local Panel_SetFGColor                = Panel.SetFGColor
local Panel_SetFontInternal           = Panel.SetFontInternal
local Panel_SetPaintBackgroundEnabled = Panel.SetPaintBackgroundEnabled
local Panel_SetParent                 = Panel.SetParent
local Panel_SetPos                    = Panel.SetPos
local Panel_SetSize                   = Panel.SetSize
local Panel_SetText                   = Panel.SetText
local Panel_SetTextInset              = Panel.SetTextInset
local Panel_SetVisible                = Panel.SetVisible

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
	local handle = vgui_CreateX ("Panel")
	
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
	local handle = vgui_CreateX ("Label")
	Panel_SetPaintBackgroundEnabled (handle, false)
	
	handle.ApplySchemeSettings = function (handle)
		self:SetLabelTextColor (view, handle, view:GetTextColor ())
	end
	
	self:InstallPanelEvents (view, handle)
	self:RegisterView (handle, view)
	
	self:SetLabelText (view, handle, view:GetText ())
	self:SetLabelFont (view, handle, view:GetFont ())
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
	Panel_SetParent (childView:GetHandle (), handle)
end

function self:RemoveChild (view, handle, childView)
	Panel_SetParent (childView:GetHandle (), nil)
end

function self:GetParent (view, handle)
	return self:GetView (handle:GetParent ())
end

function self:SetParent (view, handle, parentHandle)
	Panel_SetParent (handle, parentHandle)
end

-- Bounds
function self:GetRectangle (view, handle)
	local x, y = self:GetPosition (view, handle)
	local w, h = self:GetSize (view, handle)
	return x, y, w, h
end

function self:GetPosition (view, handle)
	local parentView = self:GetView (Panel_GetParent (handle))
	local dx, dy = 0, 0
	if parentView then dx, dy = parentView:GetContainerPosition () end
	
	local x, y = Panel_GetPos (handle)
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
	local parentView = self:GetView (Panel_GetParent (handle))
	local dx, dy = 0, 0
	if parentView then dx, dy = parentView:GetContainerPosition () end
	
	Panel_SetPos (handle, x + dx, y + dy)
end

function self:SetSize (view, handle, w, h)
	Panel_SetSize (handle, w, h)
end

-- Layout
function self:BringToFront (view, handle)
	Panel_MoveToFront (handle)
end

function self:MoveToBack (view, handle)
	Panel_MoveToBack (handle)
end

function self:InvalidateLayout (view, handle)
	Panel_InvalidateLayout (handle)
end

-- Appearance
function self:IsVisible (view, handle)
	return Panel_IsVisible (handle)
end

function self:SetVisible (view, handle, visible)
	Panel_SetVisible (handle, visible)
end

-- Mouse
function self:GetCursor (view, handle)
	return view:GetCursor ()
end

function self:SetCursor (view, handle, cursor)
	Panel_SetCursor (handle, Cursor.ToNative (cursor))
end

function self:GetMousePosition (view, handle)
	local x, y = Panel_CursorPos (handle)
	
	-- Fix coordinates by inverting the bad ScreenToLocal transform
	-- This happens when view layout is done outside of a legitimate layout event
	x, y = Panel_LocalToScreen (handle, x, y)
	
	-- Manual ScreenToLocal
	local panel = handle
	while panel do
		local dx, dy = Panel_GetPos (panel)
		x, y = x - dx, y - dy
		
		panel = Panel_GetParent (panel)
	end
	
	return x, y
end

function self:CaptureMouse (view, handle)
	MouseEventRouter:OnCaptureMouse (view)
	Panel_MouseCapture (handle, true)
end

function self:ReleaseMouse (view, handle)
	Panel_MouseCapture (handle, false)
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
	return Panel_GetText (handle)
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
	Panel_SetText (handle, text)
end

function self:SetLabelFont (view, handle, font)
	Panel_SetFontInternal (handle, font:GetId ())
end

function self:SetLabelTextColor (view, handle, textColor)
	Panel_SetFGColor (handle, Color.ToRGBA8888 (textColor))
end

function self:SetLabelHorizontalAlignment (view, handle, horizontalAlignment)
	Panel_SetContentAlignment (handle, ContentAlignment.FromAlignment (horizontalAlignment, view:GetVerticalAlignment ()))
	
	Panel_SetTextInset (handle, self.HorizontalAlignment == Glass.HorizontalAlignment.Right and 1 or 0, 0)
end

function self:SetLabelVerticalAlignment (view, handle, verticalAlignment)
	Panel_SetContentAlignment (handle, ContentAlignment.FromAlignment (view:GetHorizontalAlignment (), verticalAlignment))
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
	local methodTable = handle:GetTable ()
	
	methodTable.OnMousePressed = function (_, mouseCode)
		local mouseButtons = MouseButtons.FromNative (mouseCode)
		MouseEventRouter:OnMouseDown (view, mouseButtons, view:GetMousePosition ())
	end
	
	methodTable.OnMouseReleased = function (_, mouseCode)
		local mouseButtons = MouseButtons.FromNative (mouseCode)
		MouseEventRouter:OnMouseUp (view, mouseButtons, view:GetMousePosition ())
	end
	
	methodTable.OnMouseWheeled = function (_, delta)
		return MouseEventRouter:OnMouseWheel (view, delta)
	end
	
	methodTable.OnCursorMoved = function (_, x, y)
		local mouseButtons = MouseButtons.Poll ()
		MouseEventRouter:OnMouseMove (view, mouseButtons, view:GetMousePosition ())
	end
	
	methodTable.OnCursorEntered = function (_)
		MouseEventRouter:OnMouseEnter (view)
	end
	
	methodTable.OnCursorExited = function (_)
		MouseEventRouter:OnMouseLeave (view)
	end
	
	handle.Paint = function (_, w, h)
		view:Render (w, h, Photon.Render2d)
	end
	
	local performLayout = methodTable.PerformLayout
	methodTable.PerformLayout = function (handle, w, h)
		if performLayout then
			performLayout (handle, w, h)
		end
		
		view:OnLayout (view:GetContainerSize ())
		view.Layout:Dispatch (view:GetContainerSize ())
	end
	
	local setVisible = handle.SetVisible
	methodTable.SetVisible = function (handle, visible)
		if handle:IsVisible () == visible then return end
		
		setVisible (handle, visible)
		
		if view:IsVisible () ~= visible then
			view:SetVisible (visible)
		end
	end
	
	local onRemove = methodTable.OnRemove
	methodTable.OnRemove = function (handle)
		if onRemove then
			onRemove (handle)
		end
		
		self:UnregisterView (handle, view)
		view:OnHandleDestroyed ()
	end
end

GarrysMod.Environment = GarrysMod.Environment ()
