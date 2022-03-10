
-- Variables that are used on both client and server

SWEP.PrintName		= "Laser Mine" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= "Isemenuk27"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 80
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/props_lab/tpplug.mdl"
SWEP.WorldModel		= "models/props_lab/tpplug.mdl"
SWEP.Slot			= 4
SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= -1			-- Size of a clip
SWEP.Primary.DefaultClip	= 1		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "ammo_zp_laser"

SWEP.Secondary.ClipSize		= -1		-- Size of a clip
SWEP.Secondary.DefaultClip	= -1		-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= false		-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"

SWEP.PlaceDist = 64

SWEP.ViewModelPosOffset =  Vector(9.96, 8.43, 20.399)
SWEP.ViewModelAngOffset = Vector(-80, 0, 0)

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/zp_laser")
	killicon.Add( "zp_laser_weapon", "vgui/zp_laser_kill", Color(255, 255, 255, 255) )
end

function SWEP:Initialize()
	util.PrecacheModel(self.WorldModel)
	self:SetHoldType( "slam" )
end
local function getPlaceableENT()
	for i, ent in ipairs( ents.GetAll() ) do 
		if ent:IsNPC() || ent:IsPlayer() then
			return ent
		end
	end
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	if IsFirstTimePredicted() then
		self:SpawnMine()
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
		self:SetNextPrimaryFire(CurTime() + 0.2)
	end
end

function SWEP:SpawnMine()
	local owner = self:GetOwner()

	if (!IsValid(owner)) then return end
	if (CLIENT) then return end

	local trace = {}
	trace.start = owner:EyePos()
	trace.endpos = owner:EyePos() + owner:GetAimVector() * self.PlaceDist
	trace.filter = owner, self
	local trace = util.TraceLine(trace)
	if !trace.Hit then return end
	if trace.Entity:IsNPC() then return end
	if trace.Entity:IsPlayer() then return end

	local laserEnt = ents.Create("zp_laser")
	if (!laserEnt:IsValid()) then return end
	laserEnt:SetPos(trace.HitPos)
	laserEnt:SetAngles((trace.HitNormal * 90):Angle())
	laserEnt:Spawn()
	laserEnt:SetOwner(owner)
	local weld = constraint.Weld( laserEnt, trace.Entity, 0, trace.PhysicsBone, 0, collision == 0, false )

	if engine.ActiveGamemode() == "sandbox" then

	cleanup.Add( owner, "props", ent )
 
	undo.Create( "Laser Mine" )
		undo.AddEntity( laserEnt )
		undo.SetPlayer( owner )
	undo.Finish()
	end

	self:TakePrimaryAmmo( 1 )
	self:ShootEffects()
	if self:Ammo1() <= 0 then self:Remove() end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:CalcViewModelView( ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng )
	--ViewModel:SetNoDraw(true)
	--ViewModel:SetColor(Color(255, 255, 255, 255))
	if ViewModel:GetRenderMode() != RENDERMODE_TRANSCOLOR then
		ViewModel:SetRenderMode( RENDERMODE_TRANSCOLOR )
	end
	local owner = self:GetOwner()
	if (!owner:IsValid()) then return end
	if (!owner:Alive()) then return end
	local trace = {}
	trace.start = owner:EyePos()
	trace.endpos = owner:EyePos() + owner:GetAimVector() * self.PlaceDist
	trace.filter = owner, self
	local trace = util.TraceLine(trace)

	if !trace.Hit || trace.Entity:IsNPC() || trace.Entity:IsPlayer() then
		ViewModel:SetNoDraw(false)
		ViewModel:SetColor(Color(255, 255, 255, 255))
		local NewEyeAng, NewEyePos = OldEyeAng, OldEyePos
		local vm_origin = (EyePos - OldEyePos)
		local vm_angles = (EyeAng - OldEyeAng)

		NewEyeAng = NewEyeAng * 1
        
		NewEyeAng:RotateAroundAxis(NewEyeAng:Right(), 	self.ViewModelAngOffset.x)
		NewEyeAng:RotateAroundAxis(NewEyeAng:Up(), 		self.ViewModelAngOffset.y)
		NewEyeAng:RotateAroundAxis(NewEyeAng:Forward(),   self.ViewModelAngOffset.z)

	local Right 	= NewEyeAng:Right()
	local Up 		= NewEyeAng:Up()
	local Forward 	= NewEyeAng:Forward()

	NewEyePos = NewEyePos + self.ViewModelPosOffset.x * Right
	NewEyePos = NewEyePos + self.ViewModelPosOffset.y * Forward
	NewEyePos = NewEyePos + self.ViewModelPosOffset.z * Up

	NewEyePos = NewEyePos - vm_origin
	NewEyeAng = NewEyeAng - vm_angles
		return NewEyePos, NewEyeAng
	end

		local vmPos, vmAng = OldEyePos, OldEyeAng
		vmPos = trace.HitPos
		vmAng = (trace.HitNormal * 90):Angle()
		ViewModel:SetNoDraw(false)
		ViewModel:SetColor(Color(255, 255, 255, 120))
		return vmPos, vmAng
end

function SWEP:Think()

end

function SWEP:Holster( wep )
	local vm = self:GetOwner():GetViewModel()
	if !IsValid(vm) then return end
	vm:SetColor(Color(255, 255, 255, 255))
	return true
end

function SWEP:Deploy()
	return true
end

function SWEP:ShootEffects()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )		-- View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )		-- 3rd Person Animation

end

function SWEP:TakePrimaryAmmo( num )

	self.Owner:RemoveAmmo( num, self:GetPrimaryAmmoType() )

end

function SWEP:TakeSecondaryAmmo( num )

	if ( self:Clip2() <= 0 ) then

		if ( self:Ammo2() <= 0 ) then return end

		self.Owner:RemoveAmmo( num, self:GetSecondaryAmmoType() )

	return end

	self:SetClip2( self:Clip2() - num )

end

function SWEP:CanPrimaryAttack()
	if self:Ammo1() <= 0 then
		return false
	end
	return true
end

function SWEP:CanSecondaryAttack()

	if ( self:Clip2() <= 0 ) then

		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextSecondaryFire( CurTime() + 0.2 )
		return false

	end

	return true

end

function SWEP:OnRemove()
	local ply = self:GetOwner()
	if !ply:IsValid() then return end
	local vm = ply:GetViewModel()
	if !IsValid(vm) then return end
	vm:SetColor(Color(255, 255, 255, 255))
	return true
end

function SWEP:OwnerChanged()
end

function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() )
end

function SWEP:Ammo2()
	return self.Owner:GetAmmoCount( self:GetSecondaryAmmoType() )
end

function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

function SWEP:DoImpactEffect( tr, nDamageType )
	return false

end

if CLIENT then
	local WorldModel = ClientsideModel(SWEP.WorldModel)
	WorldModel:SetSkin(1)
	WorldModel:SetNoDraw(true)

	function SWEP:DrawWorldModel()
		local _Owner = self:GetOwner()

		if (IsValid(_Owner)) then
			local offsetVec = Vector(4.69 - 3, 2.687 - 5, -8.91)
			local offsetAng = Angle(100.886 - 180, -8.742, -6.134)
			
			local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand")

			local pos, ang = _Owner:GetBonePosition(boneid)

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, pos, ang)

			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)

           WorldModel:SetupBones()
           WorldModel:DrawModel()
		else
			self:DrawModel()
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		
	end
end