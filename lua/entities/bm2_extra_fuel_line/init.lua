AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/bitminers2/bm2_extra_fuel_plug.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local physics = self:GetPhysicsObject()
	if (physics:IsValid()) then
		physics:Wake()
		physics:SetMass(1)
	end

	self:SetHealth(25)
	self:SetUseType(SIMPLE_USE)

	--Spawn the other end of the line
	self.plug = ents.Create("bm2_extra_fuel_otherend")
	self.plug:SetPos(self:GetPos() + Vector(0,0,5))
	self.plug:Spawn()
	self.plug.otherEnd = self
	self.plug.parent = self
	self.otherEnd = self.plug

	--Connect the lines
	self.rope = constraint.Rope(self, self.plug, 0, 0, Vector(0,0,0), Vector(0,0,0), 200, 0, 0, 2.5, "bitminers2/fuel_line", false)
	self.otherEnd.rope = self.rope
	self.connectedDevice = nil
end


function ENT:GetConnectedDevice()
	return self.plug.connectedDevice
end

function ENT:OnPlugedIn(position, angle, parent)
	if IsValid(self.rope) then
		self.rope:Remove()
	end

	local blank = ""
	if self:GetConnectedDevice() == nil then
		blank, self.rope = constraint.Rope(parent, self.plug, 0, 0, parent:WorldToLocal(position), Vector(0,0,0), 200, 50, 0,  2.5, "bitminers2/fuel_line", false)
		self.otherEnd.rope = self.rope
	else
		blank, self.rope = constraint.Rope(parent, self.plug.connectedDevice, 0, 0, parent:WorldToLocal(position), self.plug.connectedDevice:WorldToLocal(self.plug:GetPos()), 200, 50, 0,  2.5, "bitminers2/fuel_line", false)
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
	if class == "bm2_extra_fuel_tank" or class == "bm2_generator" then
		if self.connectedDevice == nil and ent.connectedPlug == nil then
			if self:GetConnectedDevice() ~= nil then 
				if ent:GetClass() == self.otherEnd.connectedDevice:GetClass() then
					return
				end
			end
			local worked, pos, ang = nil

			if class == "bm2_extra_fuel_tank" then
				worked, pos, ang = ent:PlugIn(self)
			elseif class == "bm2_generator" then
				worked, pos, ang = ent:PlugInFuelLine(self)
			end

			if worked then
				self:OnPlugedIn(pos, ang, ent)
			end
		end
	end
end

function ENT:UnPlug()
	if self.connectedDevice ~= nil then
		if IsValid(self.rope) then
			self.rope:Remove()
		end
		local blank = ""
		self:SetParent()
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.connectedDevice:Unplug(self)
		self.connectedDevice.connectedFuelLine = nil
		self.connectedDevice = nil

		if self.plug.connectedDevice == nil then
			blank, self.rope = constraint.Rope(self, self.plug, 0, 0, Vector(0,0,0), Vector(0,0,0), 200, 50, 0,  2.5, "bitminers2/fuel_line", false)
			self.otherEnd.rope = self.rope
		else
			blank, self.rope = constraint.Rope(self, self.plug.connectedDevice, 0, 0, Vector(0,0,0), self.plug.connectedDevice:WorldToLocal(self.plug:GetPos()), 200, 50, 0,  2.5, "bitminers2/fuel_line", false)
			self.otherEnd.rope = self.rope
		end 
	end
end

function ENT:Use(act, caller)
	self:UnPlug()
end

function ENT:OnRemove()
	self.plug.parent = nil
	self.plug:Remove()

	if self.connectedDevice then
		self.connectedDevice.connectedFuelLine = nil
		self.connectedDevice = nil
	end
end