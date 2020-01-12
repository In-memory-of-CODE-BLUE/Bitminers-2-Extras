ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Fuel Tank"
ENT.Spawnable = true
ENT.Category = "Bitminers 2 Extras"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 3, "ShowNoFuelWarning")
	self:NetworkVar("Int",0, "FuelLevel")
end