AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/bitminers2/bm2_solar_plug.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
	end

	self:SetHealth(25)

	self:SetUseType(SIMPLE_USE)

	self.connectedDevice = nil

end	

function ENT:GetConnectedDevice()
	if self.parent.connectedDevice ~= nil then
		return self.parent.connectedDevice
	else
		return nil
	end
end

function ENT:OnPlugedIn(position, angle, parent)
	constraint.RemoveConstraints(self, "Rope")
	
	if self.parent.connectedDevice == nil then
		self.rope = constraint.Rope(parent, self.parent, 0, 0, parent:WorldToLocal(position), Vector(0,0,0), 350, 50, 0,  1.5, "bitminers2/solar_cable", false)
		self.otherEnd.rope = self.rope
	else
		self.rope = constraint.Rope(parent, self.parent.connectedDevice, 0, 0, parent:WorldToLocal(position), self.parent.connectedDevice:WorldToLocal(self.parent:GetPos()), 350, 50, 0,  1.5, "bitminers2/solar_cable", false)
		self.otherEnd.rope = self.rope
	end 

	self.connectedDevice = parent
	self:SetAngles(angle + parent:GetAngles())
	self:SetPos(position) 
	self:SetParent(parent)
	self:SetMoveType(MOVETYPE_NONE)
end

function ENT:StartTouch(ent)
	local class = ent:GetClass()
	if class == "bm2_solarconverter" or class == "bm2_solar_panel" then
		if self.connectedDevice == nil and ent.connectedPlug == nil then
			if self.otherEnd.connectedDevice ~= nil then
				if ent:GetClass() == self.otherEnd.connectedDevice:GetClass() then
					return
				end
			end
			local worked, pos, ang = ent:PlugInSolarCable(self)
			if worked then
				self:OnPlugedIn(pos, ang, ent, true)
			end
		end
	end
end

function ENT:UnPlug()
	if self.connectedDevice ~= nil then

		if IsValid(self.rope) then
			self.rope:Remove()
		end
		
		self:SetParent()
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.connectedDevice:UnplugSolarCable(self)
		self.connectedDevice.connectedFuelLine = nil
		self.connectedDevice = nil


		local blank = ""

		if self.parent.connectedDevice == nil then
			blank, self.rope = constraint.Rope(self, self.parent, 0, 0, Vector(0,0,0), Vector(0,0,0), 350, 50, 0,  1.5, "bitminers2/solar_cable", false)
			self.otherEnd.rope = self.rope
		else
			blank, self.rope = constraint.Rope(self, self.parent.connectedDevice, 0, 0, Vector(0,0,0), self.parent.connectedDevice:WorldToLocal(self.parent:GetPos()), 350, 50, 0,  1.5, "bitminers2/solar_cable", false)
			self.otherEnd.rope = self.rope
		end 
	end
end


function ENT:Use(act, caller)
	self:UnPlug()
end

function ENT:OnRemove()
	if self.parent ~= nil then
		self.parent:Remove()		
	end

	if self.connectedDevice then
		self.connectedDevice:UnplugSolarCable(self)
		self.connectedDevice = nil
	end
end