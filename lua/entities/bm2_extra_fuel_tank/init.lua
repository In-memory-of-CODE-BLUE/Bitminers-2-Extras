AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/bitminers2/bm2_extra_fueltank.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
		physics:SetMass(225)
	end

	self:SetHealth(250)
	self:SetUseType(SIMPLE_USE)

	--The amount of fuel we have
	self.fuel = 0
	self.fuelTickTimer = 0
	self:SetFuelLevel(0)

	self.socketPosition = Vector(53,25,0)
	self.socketAngle = Angle(0,0,-90)

	self.connectedFuelLine = nil
end	

--Push fuel into any connected generator
function ENT:TickFuel()
	if self.connectedFuelLine ~= nil then
		local device = self.connectedFuelLine:GetConnectedDevice()
		if device ~= nil then
			if device:GetClass() == "bm2_generator" then
				--See how much fuel we can fit in there
				local left = 1000.0 - device.fuel
				left = math.Clamp(left,0, self.fuel)
				self.fuel = self.fuel - left
				device.fuel = device.fuel + left
			end
		end
	end
end

function ENT:Think()
	if CurTime() > self.fuelTickTimer then
		self.fuelTickTimer = CurTime() + 1
		self:TickFuel() 
		self:SetFuelLevel(self.fuel)
	end
end

//Attemps to "plug in" anouther plug into ourself, this will return false if it failes and pos, ang if it succeeds
function ENT:PlugIn(ent)
	if self.connectedFuelLine == nil then
		self.connectedFuelLine = ent

		local pos = self:GetAngles():Right() * self.socketPosition.x
		pos = pos + self:GetAngles():Forward() * self.socketPosition.z
		pos = pos + self:GetAngles():Up() * self.socketPosition.y

		//Return the position so the plug can position itself correctly
		return true, self:GetPos() + pos, self.socketAngle
	else
		return false
	end
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "bm2_fuel" or ent:GetClass() == "bm2_large_fuel" then
		if not ent.used then
			ent.used = true
			ent:Remove()
			self.fuel = math.Clamp(self.fuel + ent.fuelAmount, 0, BM2EXTRACONFIG.ExtraFuelTankSize)
			self:SetFuelLevel(self.fuel)
			self:EmitSound("ambient/water/water_splash1.wav", 75, math.random(90,110), 1)
		end
	end
end


function ENT:Unplug(ent)
	ent:SetPos(ent:GetPos() + (self:GetAngles():Right() * 16))
	self.connectedFuelLine = nil
end

function ENT:OnRemove()
	if self.connectedFuelline ~= nil then
		self.connectedFuelline:Remove()
	end
end

//Destroying it
function ENT:OnTakeDamage(damage)
	self:SetHealth(self:Health() - damage:GetDamage())
	if self:Health() <= 0 then
		if self.fuel > 0 and not BM2EXTRACONFIG.DisableFuelTankExplosion and self.exploded ~= true then
			local explode = ents.Create( "env_explosion" )
			explode:SetPos(self:GetPos())
			explode:Spawn()
			explode:SetKeyValue( "iMagnitude", "125" )
			explode:Fire( "Explode", 0, 0 )
			explode:EmitSound( "weapon_AWP.Single", 400, 400 )
			self.exploded = true
		end
		self:Remove()
	end
end

