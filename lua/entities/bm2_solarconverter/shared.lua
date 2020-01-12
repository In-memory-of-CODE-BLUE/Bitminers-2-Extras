ENT.Type = "anim"
ENT.Base = "bm2_base"

ENT.PrintName = "Solar Converter"
ENT.Spawnable = true
ENT.Category = "Bitminers 2 Extras"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 1, "IsOn" )
	self:NetworkVar( "Bool", 2, "ShowToMuchPowerWarning")
	self:NetworkVar( "Bool", 3, "ShowNoPowerWarning")
	self:NetworkVar( "Bool", 4, "ShowNoConnectedSolarWarning")
	self:NetworkVar( "Float", 2, "PowerConsumpsion")
	self:NetworkVar( "Float", 3, "MaxPowerConsumpsion")
	self:NetworkVar( "Int", 1, "ConnectedPanels")
end 