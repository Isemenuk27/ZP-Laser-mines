
EFFECT.Mat = Material( "effects/blueblacklargebeam" )
function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Entity = data:GetEntity()
	self.Pos = self.Entity:GetPos() || self.Position
	self:SetRenderBoundsWS( self.Pos, self.EndPos )
end

function EFFECT:Think()
	if !IsValid(self.Entity) then return false end

	self.Pos = self.Entity:GetNWVector("zp_laser_pos") || self.Entity:GetPos()
	self.EndPos = self.Entity:GetNWVector("zp_laser_end")
	self:SetRenderBoundsWS( self.Pos, self.EndPos )

	if self.Entity:GetNWBool("zp_laser_broken") then return false end
	if self.Entity:GetNWBool("zp_laser_upd") then return false end
	return true
end
function EFFECT:Render()
	if !IsValid(self.Entity) then return false end
	render.SetMaterial( self.Mat )
	render.DrawBeam(self.Pos, self.EndPos, 2, 0, 1, Color( 0, 25, 255 ))
end