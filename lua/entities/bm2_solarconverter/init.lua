AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

sound.Add( {
	name = "bm2_electric", 
	channel = CHAN_AUTO,
	volume = 0.075,
	level = 65,
	pitch = { 110, 110 },
	sound = "bitminers2/hi-tensionpower.wav"
} )

function ENT:Initialize()
	self:SetModel("models/bitminers2/bm2_solar_converter.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
	end

	self:SetRenderMode(RENDERMODE_TRANSTEXTURE)
	self:SetHealth(1000)
	self.soundPlaying = false
	self.connectedEntity = nil

	//This is a table of socket infomation such as socket position, angle, and if something is plugged in or not
	self.sockets = {
		[1] = {
			position = Vector(-3.5,4,18.2),
			angle = Angle(0,90,0),
			pluggedInEntity = nil
		},
		[2] = {
			position = Vector(3.5,4,18.2),
			angle = Angle(0,90,0),
			pluggedInEntity = nil 
		}
	}

	self.solarsockets = {
		[1] = {
			position = Vector(-25,8.5,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[2] = {
			position = Vector(-19.5,4.8,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[3] = {
			position = Vector(-25 + (11.15 * 1),8.5,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[4] = {
			position = Vector(-19.5 + (11.15 * 1),4.8,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[5] = { ---13.85
			position = Vector(-25 + (11.15 * 2),8.5,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[6] = {
			position = Vector(-19.5 + (11.15 * 2),4.8,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[7] = { ---13.85
			position = Vector(-25 + (11.15 * 3),8.5,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[8] = {
			position = Vector(-19.5 + (11.15 * 3),4.8,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[9] = { ---13.85
			position = Vector(-25 + (11.15 * 4),8.5,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		},
		[10] = {
			position = Vector(-19.5 + (11.15 * 4),4.8,-22.2),
			angle = Angle(0,0,0),
			pluggedInEntity = nil
		}
	}

	//Max amount of watt to output (in KW)
	self.maxPowerOut = 0
	self.solarTickTimer = CurTime()
end	

function ENT:PlugInSolarCable(ent)
	//Find empty socket
	for i, b in ipairs(self.solarsockets) do
		if self.solarsockets[i].pluggedInEntity == ent or self.solarsockets[i].pluggedInEntity == ent.otherEnd then
			return false
		end
	end

	local emptySocket = -1
	for i, b in ipairs(self.solarsockets) do
		if b.pluggedInEntity == nil then
			emptySocket = i
			break
		end
	end

	//We found a slot
	if emptySocket ~= -1 then
		self.solarsockets[emptySocket].pluggedInEntity = ent

		local pos = self:GetAngles():Right() * self.solarsockets[emptySocket].position.x
		pos = pos + self:GetAngles():Forward() * self.solarsockets[emptySocket].position.z
		pos = pos + self:GetAngles():Up() * self.solarsockets[emptySocket].position.y

		//Return the position so the plug can position itself correctly
		return true, self:GetPos() + pos, self.solarsockets[emptySocket].angle
	end

	//We failes :c
	return false
end

function ENT:UpdatePowerToBitminers(bitminers, shouldPower)
	for k, v in pairs(bitminers) do
		v:SetHasPower(shouldPower)
	end
end
 
function ENT:TickSolarCheck()
	local totalActiveSolarPanels = 0
	local totalConnectedSolarPanel = 0

	for k, v in pairs(self.solarsockets) do
		if v.pluggedInEntity ~= nil then
			local connectedSolarPanel = v.pluggedInEntity:GetConnectedDevice()
			if connectedSolarPanel ~= nil then
				if connectedSolarPanel:CheckLight() then
					totalActiveSolarPanels = totalActiveSolarPanels + 1
				end
				totalConnectedSolarPanel = totalConnectedSolarPanel + 1
			end
		end
	end
	self:SetConnectedPanels(totalConnectedSolarPanel)

	if totalConnectedSolarPanel > 0 then
		self:SetShowNoConnectedSolarWarning(false)
		self:SetShowNoConnectedSolarWarning(false)
		self:SetMaxPowerConsumpsion(100 * totalActiveSolarPanels)
		local connectedBitminers = BM2GetConnectedMiners(self)
		if connectedBitminers == false then 
			self:SetPowerConsumpsion(0)
			return 
		end

		local availablePower = 100 * totalActiveSolarPanels
		local requiredPower = 0
		for k ,v in pairs(connectedBitminers) do
			if v.miningState then
				requiredPower = requiredPower + (v.powerUsage * 100)
			end
		end
		self:SetPowerConsumpsion(requiredPower)

		if availablePower >= requiredPower then
			self:SetIsOn(true)
			self:UpdatePowerToBitminers(connectedBitminers, true)
			self:SetShowToMuchPowerWarning(false)
			for k ,v in pairs(connectedBitminers) do
				if v.miningState then
					v:MineBitcoin() //Also mines the bitcoins to keep them all in sync with each other
				end
			end
			if requiredPower > 0 then
				if not self.soundPlaying and BM2CONFIG.GeneratorsProduceSound then
					self:EmitSound("bm2_electric")
					self.soundPlaying = true
				end
			else
				if self.soundPlaying then
					self:StopSound("bm2_electric")
					self.soundPlaying = false
				end
			end
		else
			self:SetShowToMuchPowerWarning(true)
			self:UpdatePowerToBitminers(connectedBitminers, false)
			self:SetIsOn(false)
			if self.soundPlaying then
				self:StopSound("bm2_electric")
				self.soundPlaying = false
			end
		end
	else 
		self:SetShowNoConnectedSolarWarning(true)
		self:SetPowerConsumpsion(0)
		self:SetIsOn(false)
		if self.soundPlaying then
			self:StopSound("bm2_electric")
			self.soundPlaying = false
		end
	end
end

function ENT:UnplugSolarCable(ent)
	for i, b in ipairs( self.solarsockets) do
		if self.solarsockets[i].pluggedInEntity == ent then
			self.solarsockets[i].pluggedInEntity = nil
			return
		end
	end
end

function ENT:Think()
	if CurTime() > self.solarTickTimer then
		self.solarTickTimer = CurTime() + 1
		self:TickSolarCheck() 
	end
end

//Attemps to "plug in" anouther plug into ourself, this will return false if it failes and pos, ang if it succeeds
function ENT:PlugIn(ent)
	//We dont want to plug something in that does not fit ;D
	if ent:GetClass() ~= "bm2_plug_1" then return false end 

	//Find empty socket
	local emptySocket = -1
	for i, b in ipairs( self.sockets) do
		if self.sockets[i].pluggedInEntity == nil then
			emptySocket = i
			break
		end
	end

	//We found a slot
	if emptySocket ~= -1 then
		self.sockets[emptySocket].pluggedInEntity = ent

		local pos = self:GetAngles():Right() * self.sockets[emptySocket].position.x
		pos = pos + self:GetAngles():Forward() * self.sockets[emptySocket].position.z
		pos = pos + self:GetAngles():Up() * self.sockets[emptySocket].position.y

		//Return the position so the plug can position itself correctly
		return self:GetPos() + pos, self.sockets[emptySocket].angle
	end

	//We failes :c
	return false
end

//Used to disconnect the plug from the entity its pluged into (the generator)
function ENT:Unplug(plug)
	for i, b in ipairs( self.sockets) do
		if self.sockets[i].pluggedInEntity == plug then
			self.sockets[i].pluggedInEntity = nil //unplug
		end
	end
end

function ENT:OnRemove()
	for i, v in ipairs(self.sockets) do
		if v.pluggedInEntity ~= nil then
			v.pluggedInEntity:UnPlug()
		end
	end
	self:StopSound("bm2_electric")
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "bm2_fuel" then
		if not ent.used then
			ent.used = true
			ent:Remove()
			self.fuel = math.Clamp(self.fuel + ent.fuelAmount, 0, 1000)
			self:EmitSound("ambient/water/water_splash1.wav", 75, math.random(90,110), 1)
		end
	end
end

