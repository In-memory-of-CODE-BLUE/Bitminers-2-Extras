AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/bitminers2/bm2_solar_panel.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
	end

	self:SetHealth(1000)

	self:SetUseType(SIMPLE_USE)

	self.connectedPlug = nil

	self.socketPosition = Vector(-0.3,19.4,-41.65)
	self.socketAngle = Angle(0,0,0)
	self:SetHasLight(true)
end	

--Returns true or false if the solar panel has light
function ENT:CheckLight()
	if not BM2EXTRACONFIG.DisableLightRequirment then
		local tr = util.TraceLine( {
			start = self:GetPos() + Vector(0,0,10),
			endpos = self:GetPos() + Vector(0,0,100000000),
			filter = self
		} )

		self:SetHasLight(tr.HitSky)
		return tr.HitSky
	else
		self:SetHasLight(true)
		return true
	end
end

function ENT:PlugInSolarCable(ent)
	if self.connectedPlug == nil then
		self.connectedPlug = ent

		local pos = self:GetAngles():Right() * self.socketPosition.x
		pos = pos + self:GetAngles():Forward() * self.socketPosition.z
		pos = pos + self:GetAngles():Up() * self.socketPosition.y

		//Return the position so the plug can position itself correctly
		return true, self:GetPos() + pos, self.socketAngle
	else
		return false
	end
end

function ENT:UnplugSolarCable(ent)
	self.connectedPlug = nil
	self:SetHasLight(true)
end

function ENT:OnRemove()
	if self.connectedPlug ~= nil then
		self.connectedPlug:Remove()
	end
end