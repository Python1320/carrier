local self = {}
Glass.Glyph = Class (self)

function self:ctor (w, h, renderer)
	self.Width  = w
	self.Height = h
end

function self:GetSize ()
	return self.Width, self.Height
end

function self:GetWidth ()
	return self.Width
end

function self:GetHeight ()
	return self.Height
end

function self:Render (render2d)
	renderer (render2d)
end
