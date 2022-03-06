AddCSLuaFile()

DEFINE_BASECLASS( "zp_laser" )

ENT.PrintName = "Laser Mine"
ENT.Author = "Isemenuk27"
ENT.Information = ""
ENT.Base = "base_gmodentity"
ENT.Category = "Fun + Games"

ENT.Model = "models/props_lab/tpplug.mdl"

ENT.LaserDist = 2600
ENT.Damage = 15
ENT.EntHealth = 40
ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.HitWorld = true
ENT.NextEffect = CurTime()
ENT.PlaceSound = {
	"npc/roller/blade_cut.wav"
}
ENT.ReadySound = {
	"weapons/stunstick/spark1.wav",
	"weapons/stunstick/spark2.wav",
	"weapons/stunstick/spark3.wav"
}
ENT.DestroySound = {
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap4.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
}
ENT.FleshImpact = {
	"physics/flesh/flesh_impact_bullet1.wav",
	"physics/flesh/flesh_impact_bullet2.wav",
	"physics/flesh/flesh_impact_bullet3.wav",
	"physics/flesh/flesh_impact_bullet4.wav"
}
function ENT:SpawnFunction( ply, tr, ClassName )
	if ( CLIENT ) then return end
	if ( !tr.Hit ) then return end

	local ent = ents.Create( "zp_laser" )
	ent:SetAngles( tr.HitNormal:Angle() )
	
	ent:SetPos( tr.HitPos  )

	ent:Spawn()
	ent:Activate()
	
	local weld = constraint.Weld( ent, tr.Entity, 0, tr.PhysicsBone, 0, collision == 0, false )

	return ent
end

function ENT:Initialize()
	if ( CLIENT ) then return end
	self:SetNWBool("Ready", false)
	self:SetModel( self.Model )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	

	self:SetHealth(1)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMaterial("weapon")
		phys:EnableGravity(true)
		phys:SetMass(2)
		phys:Wake()
		self:EmitSound(self.PlaceSound[math.random(1, #self.PlaceSound)], 75, 100, 1, CHAN_AUTO)

		timer.Create("zp_ready_timer" .. tostring(self:EntIndex()), 1, 1, function() self:Ready() end)
	end
end

function ENT:Ready()
	--if CLIENT then return end
	self:EmitSound(self.ReadySound[math.random(1, #self.ReadySound)], 75, 100, 1, CHAN_AUTO)
	self:SetNWBool("Ready", true)
	self:SetBodygroup(0, 1)
	local endPosEnt = self:GetAngles():Forward()
end

function math.RoundVector(InputV, Dec)
	local outputX = math.Round( InputV.x, Dec )
	local outputY = math.Round( InputV.y, Dec )
	local outputZ = math.Round( InputV.z, Dec )
	return Vector(outputX, outputY, outputZ)
end

function ENT:Think()
	if !self:GetNWBool("Ready") then return end
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	local phys = self:GetPhysicsObject()
	local endPosEnt = self:GetAngles():Forward()
	local trace = {}
	trace.start = self:GetPos() + endPosEnt * 5
	trace.endpos = self:GetPos() + endPosEnt * self.LaserDist
	trace.filter = {self, self:GetOwner()}
	trace.mins = Vector( 8, 0, 8 )
	trace.maxs = Vector( -8, -0, -8 )
	trace.mask = MASK_SHOT_HULL
	local trace = util.TraceHull( trace )

	local effcttrace = {}
	effcttrace.start = self:GetPos()
	effcttrace.endpos =  self:GetPos() + endPosEnt * self.LaserDist
	effcttrace.filter = {self, self:GetOwner()}
	local effcttrace = util.TraceLine(effcttrace)
	if trace.HitSky then return false end

	self:SetNWBool("zp_laser_upd", true)



	local effectdata = EffectData()
		effectdata:SetEntity( self )
		effectdata:SetOrigin( effcttrace.HitPos )
		effectdata:SetStart( effcttrace.StartPos )
	util.Effect( "zp_laser", effectdata )
	if effcttrace.Hit then
		if self.NextEffect < CurTime() then
			local effect = EffectData()
				effect:SetOrigin( effcttrace.HitPos )
				effect:SetMagnitude(1)
				effect:SetScale(0.1)
				effect:SetNormal(effcttrace.HitNormal)
				effect:SetRadius(1)
			util.Effect( "ElectricSpark", effect )

			self.NextEffect = CurTime() + 0.1
		end
	end
	if trace.Hit then
		if SERVER then 
			local killOwner = self:GetOwner()
			if !killOwner:IsPlayer() then killOwner = self end
			trace.Entity:TakeDamage( self.Damage, killOwner, self )
			if trace.MatType  == MAT_FLESH then
				trace.Entity:EmitSound(self.FleshImpact[math.random(1, #self.FleshImpact)], 75, 100, 1, CHAN_AUTO)
			end
		end



	end
	return false
end

function ENT:OnRemove()
	self:SetNWBool("zp_laser_broken", true)
	timer.Remove("zp_ready_timer" .. tostring(self:EntIndex()))
	timer.Remove("zp_kill_timer" .. tostring(self:EntIndex()))
end

function ENT:OnTakeDamage( dmginfo )
	local origin = self:GetPos()
	local effect = EffectData()
	effect:SetOrigin( origin )
	util.Effect( "cball_bounce", effect )
	self.EntHealth = self.EntHealth - dmginfo:GetDamage()
	if self.EntHealth > 1 then return end
	timer.Remove("zp_ready_timer" .. tostring(self:EntIndex()))

	self:SetNWBool("Ready", false)
	self:SetNWBool("zp_laser_broken", true)

	self:EmitSound(self.DestroySound[math.random(1, #self.DestroySound)], 75, 100, 1, CHAN_AUTO)
	
	
	local phys = self:GetPhysicsObject()
	phys:Wake()
	phys:SetMass(1)

	--self:SetMaterial("models/props_pipes/guttermetal01a")


	local unweld = constraint.RemoveConstraints( self, "Weld")
	
	timer.Create("zp_kill_timer" .. tostring(self:EntIndex()), math.Rand(1, 7), 1, function()
		local effect = EffectData()
			effect:SetOrigin( self:GetPos() )
			effect:SetMagnitude(10)
			effect:SetScale(10)
			effect:SetEntity(self)
			effect:SetFlags(1)
			effect:SetNormal(self:GetAngles():Up())
			effect:SetRadius(1)
		util.Effect( "cball_explode", effect )

		self:EmitSound(self.DestroySound[math.random(1, #self.DestroySound)], 75, 100, 1, CHAN_AUTO)
		self:Remove() 
	end)
end