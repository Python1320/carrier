local self = {}
GarrysMod.Render2d = Class (self, IRender2d)

function self:ctor ()
end

function self:DrawLine (color, x1, y1, x2, y2)
	surface.SetDrawColor (Color.ToRGBA8888 (color))
	surface.DrawLine (x1, y1, x2, y2)
end

function self:DrawRectangle (color, x, y, w, h)
	surface.SetDrawColor (Color.ToRGBA8888 (color))
	surface.DrawOutlinedRect (x, y, w, h)
end

function self:FillRectangle (color, x, y, w, h)
	surface.SetDrawColor (Color.ToRGBA8888 (color))
	surface.DrawRect (x, y, w, h)
end

GarrysMod.Render2d.Instance = GarrysMod.Render2d ()
