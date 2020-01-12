include("shared.lua")

local fuelMaterial = Material("materials/bitminers2/ui/fuel.png", "noclamp smooth")
local outputMaterial = Material("materials/bitminers2/ui/output.png", "noclamp smooth")
local warningMaterial = Material("materials/bitminers2/ui/warning.png", "noclamp smooth")

function ENT:DrawTranslucent()
	self:DrawModel()

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 350 * 350 then
		self.cam2d3dAng = LerpAngle(7 * FrameTime(), self.cam2d3dAng ~= nil and self.cam2d3dAng or Angle(0,0,0), Angle(0,LocalPlayer():GetAngles().y - 90,90))

		--Cam 2D3D for drawing infomation
		local ang = self:GetAngles()
		local pos = self:GetPos() + Vector(0,0,40) + (ang:Up() * 22)

		local alpha = 1 - math.Clamp(LocalPlayer():GetPos():DistToSqr(self:GetPos()) / (350 * 350), 0, 1)

		local color1 = Color(0,0,0,100 * alpha)
		local color2 = Color(0,0,0,255 * alpha)
		local color3 = Color(255,255,255,255 * alpha)
		local color4 = Color(255,165,0, 255 * alpha)

		cam.Start3D2D(pos, self.cam2d3dAng, 0.05)
			draw.RoundedBox(8,-200, -10 , 410, 80, color1)

			surface.SetMaterial(fuelMaterial)
			surface.SetDrawColor(color4)
			surface.DrawTexturedRect(-196,4, 56, 56)

			draw.RoundedBox(4, -130, 4 , 330, 52, Color(36,36,36,  255 * alpha))
			draw.RoundedBox(2, -128, 6 , 326, 48, Color(15,15,15, 255 * alpha))
			draw.RoundedBox(2, -128, 6 , 326 * (self:GetFuelLevel()/ BM2EXTRACONFIG.ExtraFuelTankSize), 48, color4)
			draw.SimpleText(self:GetFuelLevel().."/"..BM2EXTRACONFIG.ExtraFuelTankSize.." L", "BM2GeneratorFont", 45, 30, color2, 1, 1)
			draw.SimpleText(self:GetFuelLevel().."/"..BM2EXTRACONFIG.ExtraFuelTankSize.." L", "BM2GeneratorFont", 44, 29, color3, 1, 1)
		cam.End3D2D()
	end
end  
