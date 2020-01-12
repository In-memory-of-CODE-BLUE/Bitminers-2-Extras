ENT.Type = "anim"
ENT.Base = "bm2_base"

ENT.PrintName = "Solar Panel"
ENT.Spawnable = true
ENT.Category = "Bitminers 2 Extras"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 1, "HasLight")
end