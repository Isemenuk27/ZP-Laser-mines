
EFFECT.Mat = Material( "effects/blueblacklargebeam" )
function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Entity = data:GetEntity()
	self:SetRenderBoundsWS( self.Position, self.EndPos )
end

function EFFECT:Think()
	if !IsValid(self.Entity) then return false end
	if self.Entity:GetNWBool("zp_laser_broken") then return false end
	if self.Entity:GetNWBool("zp_laser_upd") then return false end
	return true
end
function EFFECT:Render()
	render.SetMaterial( self.Mat )
	render.DrawBeam(self.Position, self.EndPos, 2, 0, 1, Color( 0, 25, 255 ))
end