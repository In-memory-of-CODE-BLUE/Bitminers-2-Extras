include("shared.lua")

local warningMaterial = Material("materials/bitminers2/ui/warning.png", "noclamp smooth")

function ENT:DrawTranslucent()
	self:DrawModel()

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 350 * 350 then
		if self.cam2d3dAng == nil then
			self.cam2d3dAng = Angle(0,LocalPlayer():GetAngles().y - 90,90)
		else
			self.cam2d3dAng = LerpAngle(7 * FrameTime(),self.cam2d3dAng, Angle(0,LocalPlayer():GetAngles().y - 90,90))
		end
		--Cam 2D3D for drawing infomation
		local ang = self:GetAngles()
		local pos = self:GetPos() + Vector(0,0,40) - (ang:Forward() * 5) + (ang:Up() * 20)

		local alpha = 1 - math.Clamp((LocalPlayer():GetPos():Distance(self:GetPos()) / 350) * 1.1, 0, 1)

		cam.Start3D2D(pos, self.cam2d3dAng, 0.05)
			if not self:GetHasLight() then
				surface.SetMaterial(warningMaterial)
				surface.SetDrawColor(Color(255,255,255, 255))
				surface.DrawTexturedRect(-80, -20, 160, 160)

				draw.SimpleText("No sunlight!", "BM2GeneratorFont", 0, 170, Color(0,0,0, 255), 1, 1)
				draw.SimpleText("No sunlight!", "BM2GeneratorFont", -1, 170 - 1, Color(255,255,255, 255), 1, 1)

				draw.SimpleText("The solar panel needs direct sight of the skybox.", "BM2GeneratorFont", 0, 170 + 35, Color(0,0,0, 255), 1, 1)
				draw.SimpleText("The solar panel needs direct sight of the skybox.", "BM2GeneratorFont", -1, 170 - 1 + 35, Color(255,255,255, 255), 1, 1)

			end
		cam.End3D2D()
	end
end